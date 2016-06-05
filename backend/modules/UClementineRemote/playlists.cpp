#include "playlists.h"

PlayLists::PlayLists(QObject *parent) :
    QObject(parent)
{
}

PlayLists::~PlayLists()
{
}

void PlayLists::addPlayList(const pb::remote::Playlist& playList)
{
    // Create a new playlist object and store it
    PlayList* pl = new PlayList(playList);
    pl->setParent(parent());
    m_playLists[playList.id()] = pl;

    // Push the event to GUI
    Q_EMIT newPlayList(pl);
}

PlayList* PlayLists::getPlayList(int id)
{
    if(m_playLists.contains(id))
        return m_playLists[id];

    return NULL;
}

void PlayLists::serverSetActivePlayList(int id)
{
    // TODO: load this play list
    if(!m_playLists.contains(id))
        return;

    QMap<int, PlayList*>::iterator i;

    for(i = m_playLists.begin(); i != m_playLists.end(); ++i)
    {
        if(i.value()->isActive())
        {
            i.value()->setActive(true);
            break;
        }
    }

    PlayList* activePlayList = m_playLists[id];

    activePlayList->setActive(true);

    emit activePlayListChanged(activePlayList);
}
