#ifndef CLEMENTINEPROXY_H
#define CLEMENTINEPROXY_H

#include <QObject>
#include <QTcpSocket>
#include <QMutex>
#include <QSharedPointer>

#include "playlists.h"
#include "playlist.h"
#include "song.h"

#include "remotecontrolmessages.pb.h"

class ClementineProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY( QString helloWorld READ helloWorld WRITE setHelloWorld NOTIFY helloWorldChanged )
    Q_PROPERTY( PlayLists* playLists WRITE setPlayListsItem )
    Q_PROPERTY( bool isConnected READ isConnected )

public slots:
    void connectRemote(QString host, int port);
    void playNext();
    void playPrev();
    void playSong(int songIndex, int playListId);

private slots:
    void onConnected();
    void error(QAbstractSocket::SocketError socketError);
    void readyRead();

public:
    enum ConnectionStatus
    {
        Connecting,
        Connected,
        Disconnected,
        ConnectionError
    };

    Q_ENUMS(ConnectionStatus)

signals:
    void connectionStatusChanged(ConnectionStatus connectionStatus);
    void activeSongChanged(Song* song); // this event might happen when there is no play list loaded
    void updateSongPosition(int position);

    void communicationError(QString error);
    //void newMessageReceived(pb::remote::Message newMessage);

public:
    explicit ClementineProxy(QObject *parent = 0);
    ~ClementineProxy();



Q_SIGNALS:
    void helloWorldChanged();

protected:
    void processMessage(pb::remote::Message message);
    void processResponsePlaylists(pb::remote::ResponsePlaylists playLists);
    void processResponsePlaylistSongs(pb::remote::ResponsePlaylistSongs playListSongs);
    void processResponseActiveChanged(pb::remote::ResponseActiveChanged activePlaylistChanged);
    void processResponseUpdateTrackPosition(pb::remote::ResponseUpdateTrackPosition updateTrackPosition);
    void processResponseClementineInfo(pb::remote::ResponseClementineInfo clementinInfo);
    void processResponseCurrentMetadata(pb::remote::ResponseCurrentMetadata currentMetadata);

protected:
    QString helloWorld() { return m_message; }
    void setHelloWorld(QString msg) { m_message = msg; Q_EMIT helloWorldChanged(); }
    void setPlayListsItem(PlayLists* playListsItem) { m_playListsItem = playListsItem; }
    bool isConnected() { return m_clientSocket.isOpen(); }
    void play(bool playNext);

    Song* m_currentSong;

    QTcpSocket m_clientSocket;
    QString m_message;
    QByteArray readBuffer;

    PlayLists* m_playListsItem;
    //QList< QSharedPointer<PlayList> > m_playLists;
    QMutex m_socketReadLock;
};

#endif // CLEMENTINEPROXY_H

