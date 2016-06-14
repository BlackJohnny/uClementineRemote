#ifndef PLAYLISTS_H
#define PLAYLISTS_H

#include <QObject>
#include <QMap>
#include "playlist.h"

#include "remotecontrolmessages.pb.h"

class PlayLists : public QObject
{
    Q_OBJECT
    Q_PROPERTY( int size READ size )
    Q_PROPERTY( int activePlayListId READ activePlayListId)

public:
    explicit PlayLists(QObject *parent = 0);
    ~PlayLists();

Q_SIGNALS:
    void playListSongs(PlayList* playList);
    void activePlayListChanged(PlayList* playList);
    void clearPlaylists();

protected:
    int size() { return m_playLists.size(); }

public:
    void addPlayList(const pb::remote::Playlist& playList);
    void serverSetActivePlayList(int id);
    int activePlayListId() { return m_activePlayListId; }

    PlayList* getPlayList(int id);

private:
    QMap<int, PlayList*> m_playLists;
    int m_activePlayListId;
};

#endif // PLAYLISTS_H
