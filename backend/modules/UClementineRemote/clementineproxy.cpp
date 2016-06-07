#include "clementineproxy.h"
#include <QtEndian>

ClementineProxy::ClementineProxy(QObject *parent) :
    QObject(parent),
    m_currentSong(NULL),
    m_message(""),
    m_playListsItem(NULL),
    m_port(0),
    m_authCode(0)
{
    connect(&m_clientSocket, SIGNAL(connected()), this, SLOT(onConnected()), Qt::DirectConnection);
    connect(&m_clientSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(error(QAbstractSocket::SocketError)), Qt::DirectConnection);
    connect(&m_clientSocket, SIGNAL(readyRead()), this, SLOT(readyRead()), Qt::DirectConnection);

    GOOGLE_PROTOBUF_VERIFY_VERSION;

}

ClementineProxy::~ClementineProxy()
{
    if(m_clientSocket.isOpen())
        m_clientSocket.close();

    if(m_currentSong)
        delete m_currentSong;
}

void ClementineProxy::connectRemote(QString host, int port, int authCode)
{
    m_host = host;
    m_port = port;
    m_authCode = authCode;

    m_clientSocket.connectToHost(host, port);

    emit connectionStatusChanged(Connecting);
}

void ClementineProxy::playNext()
{
    play(true);
}

void ClementineProxy::playPrev()
{
    play(false);
}

void ClementineProxy::playSong(int songIndex, int playListId)
{
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::CHANGE_SONG);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::RequestChangeSong* reqChangeSong = new pb::remote::RequestChangeSong();
        reqChangeSong->set_playlist_id(playListId);
        reqChangeSong->set_song_index(songIndex);
        msg.set_allocated_request_change_song(reqChangeSong);

        uint32_t msgSize = msg.ByteSize();
        uint8_t msgData[msgSize];
        msg.SerializeToArray(msgData, msgSize);

        uint32_t beSize = qToBigEndian(msgSize);
        m_clientSocket.write((const char*)&beSize, 4);
        m_clientSocket.write((const char*)msgData, msgSize);
        m_clientSocket.flush();

        // If this playlist is loaded signal the remote to change to this play list
        if(!m_playListsItem)
            return;

        PlayList* playList = m_playListsItem->getPlayList(playListId);

        if(!playList || playList->isActive())
            return;

        if(playList->isLoaded())
            emit m_playListsItem->activePlayListChanged(playList);
        else
            requestPlayListSongs(playList->id());
    }
}
void ClementineProxy::downloadSong(int songIndex, int playListId)
{
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::DOWNLOAD_SONGS);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::RequestDownloadSongs* reqDownloadSongs = new pb::remote::RequestDownloadSongs();
        pb::remote::
        pb::remote::DownloadItem
        reqDownloadSongs->set_download_item();
        reqDownloadSongs->set_playlist_id(playListId);
        reqDownloadSongs->set_song_index(songIndex);
        msg.set_allocated_request_change_song(reqDownloadSongs);

        uint32_t msgSize = msg.ByteSize();
        uint8_t msgData[msgSize];
        msg.SerializeToArray(msgData, msgSize);

        uint32_t beSize = qToBigEndian(msgSize);
        m_clientSocket.write((const char*)&beSize, 4);
        m_clientSocket.write((const char*)msgData, msgSize);
        m_clientSocket.flush();

        // If this playlist is loaded signal the remote to change to this play list
        if(!m_playListsItem)
            return;

        PlayList* playList = m_playListsItem->getPlayList(playListId);

        if(!playList || playList->isActive())
            return;

        if(playList->isLoaded())
            emit m_playListsItem->activePlayListChanged(playList);
        else
            requestPlayListSongs(playList->id());
    }
}
void ClementineProxy::requestPlayLists()
{
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::REQUEST_PLAYLISTS);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::RequestPlaylists* reqPlayLists = new pb::remote::RequestPlaylists();
        reqPlayLists->set_include_closed(false);
        msg.set_allocated_request_playlists(reqPlayLists);

        uint32_t msgSize = msg.ByteSize();
        uint8_t msgData[msgSize];
        msg.SerializeToArray(msgData, msgSize);

        uint32_t beSize = qToBigEndian(msgSize);
        m_clientSocket.write((const char*)&beSize, 4);
        m_clientSocket.write((const char*)msgData, msgSize);
        m_clientSocket.flush();
    }
}

void ClementineProxy::requestPlayListSongs(int playListId)
{
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::REQUEST_PLAYLIST_SONGS);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::RequestPlaylistSongs* reqPlayListSongs = new pb::remote::RequestPlaylistSongs();
        reqPlayListSongs->set_id(playListId);
        msg.set_allocated_request_playlist_songs(reqPlayListSongs);

        uint32_t msgSize = msg.ByteSize();
        uint8_t msgData[msgSize];
        msg.SerializeToArray(msgData, msgSize);

        uint32_t beSize = qToBigEndian(msgSize);
        m_clientSocket.write((const char*)&beSize, 4);
        m_clientSocket.write((const char*)msgData, msgSize);
        m_clientSocket.flush();
    }
}
void ClementineProxy::play(bool playNext)
{
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(playNext ? pb::remote::NEXT : pb::remote::PREVIOUS );
        msg.set_version(pb::remote::Message::default_instance().version());

        uint32_t msgSize = msg.ByteSize();
        uint8_t msgData[msgSize];
        msg.SerializeToArray(msgData, msgSize);

        uint32_t beSize = qToBigEndian(msgSize);
        m_clientSocket.write((const char*)&beSize, 4);
        m_clientSocket.write((const char*)msgData, msgSize);
        m_clientSocket.flush();
    }
}

void ClementineProxy::onConnected()
{
    qDebug() << "Connected";

    emit connectionStatusChanged(Connected);

    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::CONNECT);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::RequestConnect* reqConnect = new pb::remote::RequestConnect();
        reqConnect->set_auth_code(m_authCode);
        reqConnect->set_send_playlist_songs(true);
        msg.set_allocated_request_connect(reqConnect);

        uint32_t msgSize = msg.ByteSize();
        uint8_t msgData[msgSize];
        msg.SerializeToArray(msgData, msgSize);

        QString dataString;
        for(int i = 0; i < msgSize; i++)
            dataString.append(QString::number(msgData[i]) + " ");

        uint32_t beSize = qToBigEndian(msgSize);
        m_clientSocket.write((const char*)&beSize, 4);
        m_clientSocket.write((const char*)msgData, msgSize);
        m_clientSocket.flush();

        // Requests play lists on connect
        requestPlayLists();
    }
}

void ClementineProxy::error(QAbstractSocket::SocketError socketError)
{
    emit connectionStatusChanged(ConnectionError);
}

void ClementineProxy::readyRead()
{
    QMutexLocker locker(&m_socketReadLock);

    readBuffer.append(m_clientSocket.readAll());

    if(readBuffer.length() > 4)
    {
        // Get the message size
        uint32_t msgSize = (((uint8_t)readBuffer.at(0)) << 24) +
                            (((uint8_t)readBuffer.at(1)) << 16) +
                            (((uint8_t)readBuffer.at(2)) << 8) +
                            ((uint8_t)readBuffer.at(3));

        if(readBuffer.length() >= 4 + msgSize)
        {
            pb::remote::Message msg;
            bool parsed = msg.ParseFromArray((const void*)(readBuffer.constData() + 4), msgSize);

            if(parsed)
            {
                readBuffer.remove(0, 4 + msgSize);
                processMessage(msg);
            }
            else
            {
                // We cant recover from a protocol error
                m_clientSocket.close();

                emit connectionStatusChanged(Disconnected);
            }
        }
    }
}

void ClementineProxy::processMessage(pb::remote::Message message)
{
    //qDebug() << message.DebugString().c_str();

    if(message.version() != pb::remote::Message::default_instance().version())
        emit communicationError("Invalid version player version!");

    switch (message.type())
    {
        case pb::remote::INFO:
            qDebug() << "New message: INFO";
            processResponseClementineInfo(message.response_clementine_info());
            break;
        case pb::remote::CURRENT_METAINFO:
            qDebug() << "New message: CURRENT_METAINFO";
            processResponseCurrentMetadata(message.response_current_metadata());
            break;
        case pb::remote::UPDATE_TRACK_POSITION:
            processResponseUpdateTrackPosition(message.response_update_track_position());
            break;
        case pb::remote::KEEP_ALIVE:
            qDebug() << "New message: KEEP_ALIVE";
            //App.ClementineConnection.setLastKeepAlive(System.currentTimeMillis());
            break;
        case pb::remote::SET_VOLUME:
            qDebug() << "New message: SET_VOLUME";
            //App.Clementine.setVolume(msg.getRequestSetVolume().getVolume());
            break;
        case pb::remote::PLAY:
            qDebug() << "New message: PLAY";
            //App.Clementine.setState(Clementine.State.PLAY);
            break;
        case pb::remote::PAUSE:
            qDebug() << "New message: PAUSE";
            //App.Clementine.setState(Clementine.State.PAUSE);
            break;
        case pb::remote::STOP:
            qDebug() << "New message: STOP";
            //App.Clementine.setState(Clementine.State.STOP);
            break;
        case pb::remote::DISCONNECT:
            qDebug() << "New message: DISCONNECT";
            m_clientSocket.close();
            emit connectionStatusChanged(Disconnected);
            break;
        case pb::remote::PLAYLISTS:
            qDebug() << "New message: PLAYLISTS";
            processResponsePlaylists(message.response_playlists());
            break;
        case pb::remote::PLAYLIST_SONGS:
            qDebug() << "New message: PLAYLIST_SONGS" << message.response_playlist_songs().requested_playlist().id();
            processResponsePlaylistSongs(message.response_playlist_songs());
            break;
        case pb::remote::ACTIVE_PLAYLIST_CHANGED:
            qDebug() << "New message: ACTIVE_PLAYLIST_CHANGED";
            processResponseActiveChanged(message.response_active_changed());
            break;
        case pb::remote::REPEAT:
            qDebug() << "New message: REPEAT";
            //parseRepeat(msg.getRepeat());
            break;
        case pb::remote::SHUFFLE:
            qDebug() << "New message: SHUFFLE";
            //parseShuffle(msg.getShuffle());
            break;
        case pb::remote::LYRICS:
            qDebug() << "New message: LYRICS";
            //parseLyrics(msg.getResponseLyrics());
            break;
        case pb::remote::SONG_FILE_CHUNK:
            qDebug() << "New message: SONG_FILE_CHUNK";
            processResponseSongFileChunk(message.response_song_file_chunk());
            break;
        case pb::remote::DOWNLOAD_QUEUE_EMPTY:
            qDebug() << "New message: DOWNLOAD_QUEUE_EMPTY";
            break;

        default:
            qDebug() << "New message: Unknown message type" << message.type();
            break;
    }
}

void ClementineProxy::processResponseClementineInfo(pb::remote::ResponseClementineInfo clementineInfo)
{
}

void ClementineProxy::processResponseCurrentMetadata(pb::remote::ResponseCurrentMetadata currentMetadata)
{
    if(m_currentSong)
        delete m_currentSong;

    m_currentSong = new Song(currentMetadata.song_metadata());

    emit activeSongChanged(m_currentSong);
}

void ClementineProxy::processResponseSongFileChunk(pb::remote::ResponseSongFileChunk songFileChunk)
{
}

void ClementineProxy::processResponsePlaylists(pb::remote::ResponsePlaylists playLists)
{
    if(!m_playListsItem)
        return;

    // First clear the existing play list
    emit m_playListsItem->clearPlaylists();

    int currentPlayListId;

    for(int i = 0; i < playLists.playlist_size(); i++)
    {
        m_playListsItem->addPlayList(playLists.playlist(i));
    }

    // Request the songs for the active playlist
    requestPlayListSongs(m_playListsItem->activePlayListId());

    qDebug() << "update playlists";
}

void ClementineProxy::processResponsePlaylistSongs(pb::remote::ResponsePlaylistSongs playListSongs)
{
    if(!m_playListsItem)
        return;

    PlayList* pl = m_playListsItem->getPlayList(playListSongs.requested_playlist().id());

    // TODO: is this a real use case? ... add the list maybe
    if(pl == NULL)
        return;

    // Add the songs to the specified playlist
    for(int i = 0; i < playListSongs.songs_size(); i++)
    {
        pl->addSong(playListSongs.songs(i));
    }

    if(pl->isActive())
        emit m_playListsItem->playListSongs(pl);
}

void ClementineProxy::processResponseActiveChanged(pb::remote::ResponseActiveChanged activePlaylistChanged)
{
    if(!m_playListsItem)
        return;

    m_playListsItem->serverSetActivePlayList(activePlaylistChanged.id());
}

void ClementineProxy::processResponseUpdateTrackPosition(pb::remote::ResponseUpdateTrackPosition updateTrackPosition)
{
    emit updateSongPosition(updateTrackPosition.position());
}
