#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QString>
#include "remotecontrolmessages.pb.h"

class PlayList
{
public:
    PlayList();
    PlayList(const pb::remote::Playlist* playList);

protected:
    QString m_name;
    bool m_isActive;
    //QList<QString> m_items;
    uint32_t m_itemsCount;
    uint32_t m_id;
};

#endif // PLAYLIST_H
