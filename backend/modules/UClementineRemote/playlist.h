#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QObject>
#include <QString>

#include "song.h"

#include "remotecontrolmessages.pb.h"

class PlayList : public QObject
{
    Q_OBJECT
    Q_PROPERTY( QString name READ name)
    Q_PROPERTY( int id READ id)
    Q_PROPERTY( bool isActive READ isActive WRITE setActive)

public slots:
    QVariantList songs();

public:
    explicit PlayList(QObject *parent = 0);
    PlayList(const pb::remote::Playlist& playList);

public:
    PlayList& operator=(const pb::remote::Playlist& playList);

    void addSong(const pb::remote::SongMetadata& songData);

public:
    QString name() { return m_name; }
    int id() { return m_id; }
    bool isActive() { return m_isActive; }
    void setActive(bool active) { m_isActive = active; }


protected:
    QString m_name;
    bool m_isActive;
    QList<Song*> m_songs;
    int m_itemsCount;
    int m_id;
};

#endif // PLAYLIST_H
