#include "clementineproxy.h"
#include <QtEndian>
#include <QStandardPaths>
#include <QDir>
#include <QCoreApplication>
#include <QQmlContext>

#include "filedownloader.h"
#include "artimageprovider.h"

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
    connect(&m_timer, SIGNAL(timeout()), this, SLOT(checkDownloadQueue()));
    m_timer.setSingleShot(false);

    GOOGLE_PROTOBUF_VERIFY_VERSION;

}

ClementineProxy::~ClementineProxy()
{
    if(m_clientSocket.isOpen())
        m_clientSocket.close();

    if(m_currentSong)
        delete m_currentSong;
}

void ClementineProxy::checkDownloadQueue()
{
    FileDownloader::DownloadStatus dlStatus = FileDownloader::getDownloadStatus();

    if(dlStatus == FileDownloader::DownloadIdle || dlStatus == FileDownloader::DownloadCompleted)
    {
        int playListId;
        QString songUrl;
        if(FileDownloader::getNextDownload(playListId, songUrl))
        {
            // Set the downloader in a wait state
            FileDownloader::newDownloadRequested();

            // Issue the download request
            requestDownloadSong(playListId, songUrl);
        }
    }
}

void ClementineProxy::connectRemote(QString host, int port, int authCode)
{
    m_host = host;
    m_port = port;
    m_authCode = authCode;

    m_clientSocket.connectToHost(host, port);

    emit connectionStatusChanged(Connecting);
}

void ClementineProxy::disconnect()
{
    if(m_clientSocket.isOpen())
        m_clientSocket.close();

    emit connectionStatusChanged(Disconnected);
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
    }
}

bool ClementineProxy::isDownloadQueueEmpty()
{
    return FileDownloader::isDownloadQueueEmpty();
}

int ClementineProxy::downloadQueueSize()
{
    FileDownloader::downloadQueueSize();
}

void ClementineProxy::downloadSong(int playListId, QString songUrl)
{
    // Register this download and let the file downloader to handle it
    FileDownloader::registerDownload(playListId, songUrl);
}

void ClementineProxy::requestDownloadSong(int playListId, QString songUrl)
{
    qDebug() << "Request download for song " << songUrl;

    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::DOWNLOAD_SONGS);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::RequestDownloadSongs* reqDownloadSongs = new pb::remote::RequestDownloadSongs();

        reqDownloadSongs->set_download_item(pb::remote::Urls);
        reqDownloadSongs->set_playlist_id(playListId);
        reqDownloadSongs->add_urls(songUrl.toStdString().c_str());

        msg.set_allocated_request_download_songs(reqDownloadSongs);

        uint32_t msgSize = msg.ByteSize();
        uint8_t msgData[msgSize];
        msg.SerializeToArray(msgData, msgSize);

        uint32_t beSize = qToBigEndian(msgSize);
        m_clientSocket.write((const char*)&beSize, 4);
        m_clientSocket.write((const char*)msgData, msgSize);
        m_clientSocket.flush();
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

void ClementineProxy::sendResponseSongOffer()
{
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::SONG_OFFER_RESPONSE);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::ResponseSongOffer* responseSongOffer = new pb::remote::ResponseSongOffer();
        responseSongOffer->set_accepted(true);
        msg.set_allocated_response_song_offer(responseSongOffer);

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

void ClementineProxy::playPause()
{
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::PLAYPAUSE);
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

void ClementineProxy::search(QString query)
{
    qDebug() << "Search for: " << query;
    if(m_clientSocket.isOpen())
    {
        pb::remote::Message msg;
        msg.set_type(pb::remote::GLOBAL_SEARCH);
        msg.set_version(pb::remote::Message::default_instance().version());

        pb::remote::RequestGlobalSearch* requestGlobalSearch = new pb::remote::RequestGlobalSearch();
        requestGlobalSearch->set_query(query.toStdString().c_str(), query.size());
        msg.set_allocated_request_global_search(requestGlobalSearch);

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
        reqConnect->set_send_playlist_songs(false);
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

        // Start the download queue timer
        m_timer.start(5000);
        FileDownloader::setDownloadDirectory(getCacheFolder());
    }
}

QString ClementineProxy::getCacheFolder()
{
    if(m_cacheFolder.isEmpty())
    {
        QStringList locations = QStandardPaths::standardLocations(QStandardPaths::GenericCacheLocation);

        if(!locations.isEmpty())
        {
            QDir dir;
            m_cacheFolder = locations.at(0) + "/" + QCoreApplication::applicationName();
            dir.mkpath(m_cacheFolder);
        }
    }

    return m_cacheFolder;
}

QString ClementineProxy::getCommunicationError()
{
    return m_clientSocket.errorString();
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

void ClementineProxy::processMessage(const pb::remote::Message& message)
{
    //qDebug() << message.DebugString().c_str();

    if(message.version() != pb::remote::Message::default_instance().version())
    {
        // TODO: better handle this case for UI feedback
        // We cant recover from a protocol error
        m_clientSocket.close();

        emit connectionStatusChanged(Disconnected);
    }

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
            emit updatePlayerStatus(ClementineProxy::Playing);
            break;
        case pb::remote::PAUSE:
            qDebug() << "New message: PAUSE";
            emit updatePlayerStatus(ClementineProxy::Paused);
            break;
        case pb::remote::STOP:
            qDebug() << "New message: STOP";
            emit updatePlayerStatus(ClementineProxy::Stopped);
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
        case pb::remote::FIRST_DATA_SENT_COMPLETE:
            qDebug() << "New message: FIRST_DATA_SENT_COMPLETE";
            break;
        case pb::remote::GLOBAL_SEARCH_RESULT:
            qDebug() << "New message: GLOBAL_SEARCH_RESULT";
            processResponseGlobalSearch(message.response_global_search());
            break;
        case pb::remote::GLOBAL_SEARCH_STATUS:
            qDebug() << "New message: GLOBAL_SEARCH_STATUS";
            break;
        default:
            qDebug() << "New message: Unknown message type" << message.type();
            break;
    }
}

void ClementineProxy::processResponseClementineInfo(const pb::remote::ResponseClementineInfo& clementineInfo)
{
}

void ClementineProxy::processResponseCurrentMetadata(const pb::remote::ResponseCurrentMetadata& currentMetadata)
{
    if(m_currentSong)
        delete m_currentSong;

    m_currentSong = new Song(currentMetadata.song_metadata());

    ArtImageProvider::setCurrentImageData(m_currentSong->art());

    emit activeSongChanged(m_currentSong);
}

void ClementineProxy::processResponseSongFileChunk(const pb::remote::ResponseSongFileChunk& songFileChunk)
{
    FileDownloader::DownloadStatus downloadStatus = FileDownloader::saveFileChunk(songFileChunk.file_number(), songFileChunk.chunk_number(), songFileChunk.chunk_count(), songFileChunk.data().c_str(), songFileChunk.data().size(), songFileChunk.song_metadata());

    if(downloadStatus == FileDownloader::DownloadStarted)
    {
        updateDownloadProgress(0, 0, songFileChunk.song_metadata().filename().c_str());
        sendResponseSongOffer();
    }
    else if(downloadStatus == FileDownloader::DownloadInProgress ||
            downloadStatus == FileDownloader::DownloadCompleted)
    {
        emit updateDownloadProgress(songFileChunk.chunk_number(), songFileChunk.chunk_count(), "");
    }
}

void ClementineProxy::processResponsePlaylists(const pb::remote::ResponsePlaylists& playLists)
{
    if(!m_playListsItem)
        return;

    QVariantList playlistsVariant;

    // First clear the existing play list
    emit m_playListsItem->clearPlaylists();

    for(int i = 0; i < playLists.playlist_size(); i++)
    {
        m_playListsItem->addPlayList(playLists.playlist(i));
        playlistsVariant.append(QVariant::fromValue(m_playListsItem->getPlayList(playLists.playlist(i).id())));
    }

    // Request the songs for the active playlist
    requestPlayListSongs(m_playListsItem->activePlayListId());

    emit updatePlayLists(playlistsVariant);

    qDebug() << "update playlists";
}

void ClementineProxy::processResponsePlaylistSongs(const pb::remote::ResponsePlaylistSongs& playListSongs)
{
    if(!m_playListsItem)
        return;

    PlayList* pl = m_playListsItem->getPlayList(playListSongs.requested_playlist().id());

    // TODO: is this a real use case? ... add the list maybe
    if(pl == NULL)
        return;

    // Clear the playlis
    pl->clear();

    // Add the songs to the specified playlist
    for(int i = 0; i < playListSongs.songs_size(); i++)
    {
        pl->addSong(playListSongs.songs(i));
    }

    if(pl->isActive())
        emit m_playListsItem->playListSongs(pl);
}

void ClementineProxy::processResponseActiveChanged(const pb::remote::ResponseActiveChanged& activePlaylistChanged)
{
    if(!m_playListsItem)
        return;

    m_playListsItem->serverSetActivePlayList(activePlaylistChanged.id());
}

void ClementineProxy::processResponseUpdateTrackPosition(const pb::remote::ResponseUpdateTrackPosition& updateTrackPosition)
{
    emit updateSongPosition(updateTrackPosition.position());
}

void ClementineProxy::processResponseGlobalSearch(const pb::remote::ResponseGlobalSearch& responseGlobalSearch)
{
    qDebug() << responseGlobalSearch.DebugString().c_str();
}
