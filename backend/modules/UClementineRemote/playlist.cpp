#include "playlist.h"
#include "templates.h"

PlayList::PlayList(QObject *parent) :
    QObject(parent),
    m_loaded(false),
    m_isActive(false)
{
}

PlayList::PlayList(const pb::remote::Playlist& playList)
{
    *this = playList;
}

PlayList::~PlayList()
{
    // Dealocate the Song pointers
    clear();
}

PlayList& PlayList::operator=(const pb::remote::Playlist& playList)
{
    m_name = playList.name().c_str();
    m_isActive = playList.active();
    m_itemsCount = playList.item_count();
    m_id = playList.id();

    return *this;
}

void PlayList::addSong(const pb::remote::SongMetadata& songData)
{
    Song* song = new Song(songData);
    song->setParent(parent());
    m_songs.append(song);

    m_loaded = true;
}

QVariantList PlayList::songs()
{
    QVariantList newList;
    QList<Song*>::iterator i;

    for(i = m_songs.begin(); i != m_songs.end(); ++i)
        newList.append(QVariant::fromValue(*i));

    return newList;
}
void PlayList::clear()
{
    QList<Song*>::iterator i;

    for(i = m_songs.begin(); i != m_songs.end(); ++i)
        delete (*i);

    m_songs.clear();
}
