#ifndef CLEMENTINEPROXY_H
#define CLEMENTINEPROXY_H

#include <QObject>
#include <QTcpSocket>
#include <QMutex>

#include "playlist.h"

#include "remotecontrolmessages.pb.h"

class ClementineProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY( QString helloWorld READ helloWorld WRITE setHelloWorld NOTIFY helloWorldChanged )

public slots:
    void connectRemote();

private slots:
    void onConnected();
    void error(QAbstractSocket::SocketError socketError);
    void readyRead();

signals:
    void connectionStatusChanged(QString newStatus);
    void communicationError(QString error);
    void updatePlaylists(QList<PlayList> playLists);
    //void newMessageReceived(pb::remote::Message newMessage);

public:
    explicit ClementineProxy(QObject *parent = 0);
    ~ClementineProxy();

Q_SIGNALS:
    void helloWorldChanged();

protected:
    void processMessage(pb::remote::Message message);
    void processResponsePlaylists(pb::remote::ResponsePlaylists playLists);
    void processResponseClementineInfo(pb::remote::ResponseClementineInfo clementinInfo);
    void processResponseCurrentMetadata(pb::remote::ResponseCurrentMetadata currentMetadata);

protected:
    QString helloWorld() { return m_message; }
    void setHelloWorld(QString msg) { m_message = msg; Q_EMIT helloWorldChanged(); }
    QTcpSocket m_clientSocket;
    QString m_message;
    QByteArray readBuffer;

    QList<PlayList> m_playLists;
    QMutex m_socketReadLock;
};

#endif // CLEMENTINEPROXY_H

