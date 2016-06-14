#ifndef CLEMENTINEPROXY_H
#define CLEMENTINEPROXY_H

#include <QObject>
#include <QTcpSocket>
#include <QMutex>
#include <QSharedPointer>
#include <QTimer>
#include <QQuickImageProvider>

#include "playlists.h"
#include "playlist.h"
#include "song.h"

#include "remotecontrolmessages.pb.h"

class ClementineProxy :
        public QObject
{
    Q_OBJECT
    Q_PROPERTY( PlayLists* playLists WRITE setPlayListsItem )
    Q_PROPERTY( bool isConnected READ isConnected )

public slots:
    void connectRemote(QString host, int port, int authCode);
    void disconnect();
    void playNext();
    void playPrev();
    void playPause();
    void playSong(int songIndex, int playListId);
    void downloadSong(int playListId, QString songUrl);
    void sendResponseSongOffer();
    void requestPlayListSongs(int playListId);
    void requestDownloadSong(int playListId, QString songUrl);
    void requestPlayLists();
    void search(QString query);
    bool isDownloadQueueEmpty();
    int downloadQueueSize();
    QString getCacheFolder();
    QString getCommunicationError();

private slots:
    void onConnected();
    void error(QAbstractSocket::SocketError socketError);
    void readyRead();
    void checkDownloadQueue();

public:
    enum ConnectionStatus
    {
        Connecting,
        Connected,
        Disconnected,
        ConnectionError
    };

    Q_ENUMS(ConnectionStatus)

    enum PlayerStatus
    {
        Stopped,
        Playing,
        Paused
    };

    Q_ENUMS(PlayerStatus)

Q_SIGNALS:
    void connectionStatusChanged(ConnectionStatus connectionStatus);
    void updatePlayLists(QVariantList playLists);
    void activeSongChanged(Song* song); // this event might happen when there is no play list loaded
    void updateSongPosition(int position);
    void updateDownloadProgress(int chunk, int chunks, QString songFileName);
    void updatePlayerStatus(PlayerStatus playerStatus);

public:
    explicit ClementineProxy(QObject *parent = 0);
    ~ClementineProxy();

protected:
    void processMessage(const pb::remote::Message& message);
    void processResponsePlaylists(const pb::remote::ResponsePlaylists& playLists);
    void processResponsePlaylistSongs(const pb::remote::ResponsePlaylistSongs& playListSongs);
    void processResponseActiveChanged(const pb::remote::ResponseActiveChanged& activePlaylistChanged);
    void processResponseUpdateTrackPosition(const pb::remote::ResponseUpdateTrackPosition& updateTrackPosition);
    void processResponseClementineInfo(const pb::remote::ResponseClementineInfo& clementinInfo);
    void processResponseCurrentMetadata(const pb::remote::ResponseCurrentMetadata& currentMetadata);
    void processResponseSongFileChunk(const pb::remote::ResponseSongFileChunk& songFileChunk);
    void processResponseGlobalSearch(const pb::remote::ResponseGlobalSearch& responseGlobalSearch);

protected:
    void setPlayListsItem(PlayLists* playListsItem) { m_playListsItem = playListsItem; }
    bool isConnected() { return m_clientSocket.isOpen(); }
    void play(bool playNext);

    QTimer m_timer;
    Song* m_currentSong;

    QTcpSocket m_clientSocket;
    QString m_message;
    QByteArray readBuffer;

    PlayLists* m_playListsItem;
    //QList< QSharedPointer<PlayList> > m_playLists;
    QMutex m_socketReadLock;

    QString m_host;
    int m_port;
    int m_authCode;
    QString m_cacheFolder;
    QImage m_currentArt;
};

#endif // CLEMENTINEPROXY_H

