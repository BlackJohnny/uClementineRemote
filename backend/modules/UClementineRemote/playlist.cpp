#include "playlist.h"

PlayList::PlayList() :
    m_isActive(false)
{
}

PlayList::PlayList(const pb::remote::Playlist* playList)
{
    m_name = playList->name().c_str();
    m_isActive = playList->active();
    m_itemsCount = playList->item_count();
    m_id = playList->id();

/*    for(int i = 0; i < playList->item_count(); i++)
    {
    }
*/
}

