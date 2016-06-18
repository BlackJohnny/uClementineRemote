#include "song.h"
#include <QDebug>

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
Song::Song(const Song& copyFrom)
{
    *this = copyFrom;
}

Song& Song::operator=(const Song& copyFrom)
{
    m_id = copyFrom.m_id;
    m_index = copyFrom.m_index;
    m_title = copyFrom.m_title;
    m_album = copyFrom.m_album;
    m_artist = copyFrom.m_artist;
    m_albumartist = copyFrom.m_albumartist;
    m_track = copyFrom.m_track;
    m_disc = copyFrom.m_disc;
    m_pretty_year = copyFrom.m_pretty_year;
    m_genre = copyFrom.m_genre;
    m_playcount = copyFrom.m_playcount;
    m_pretty_length = copyFrom.m_pretty_length;
    m_art.append(copyFrom.m_art);
    m_length = copyFrom.m_length;
    m_is_local = copyFrom.m_is_local;
    m_filename = copyFrom.m_filename;
    m_file_size = copyFrom.m_file_size;
    m_rating = copyFrom.m_rating;
    m_url = copyFrom.m_url;
    m_art_automatic = copyFrom.m_art_automatic;
    m_art_manual = copyFrom.m_art_manual;
    m_type = copyFrom.m_type;

    return *this;
}

Song::~Song()
{
}
