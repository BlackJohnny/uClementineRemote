#include "song.h"

Song::Song(QObject *parent) :
    QObject(parent)
{
}

Song::Song(const pb::remote::SongMetadata& songData)
{
    m_id = songData.id();
    m_index = songData.index();
    m_title = songData.title().c_str();
    m_album = songData.album().c_str();
    m_artist = songData.artist().c_str();
    m_albumartist = songData.albumartist().c_str();
    m_track = songData.track();
    m_disc = songData.disc();
    m_pretty_year = songData.pretty_year().c_str();
    m_genre = songData.genre().c_str();
    m_playcount = songData.playcount();
    m_pretty_length = songData.length();

    if(songData.has_art())
        m_art.append(songData.art().c_str(), songData.art().length());

    m_length = songData.length();
    m_is_local = songData.is_local();
    m_filename = songData.filename().c_str();
    m_file_size = songData.file_size();
    m_rating = songData.rating();
    m_url = songData.url().c_str();
    m_art_automatic = songData.art_automatic().c_str();
    m_art_manual = songData.art_manual().c_str();
    m_type = (SongType)songData.type();
}

Song::~Song()
{
}
