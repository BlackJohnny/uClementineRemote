#ifndef SONG_H
#define SONG_H

#include <QObject>

#include "remotecontrolmessages.pb.h"

class Song : public QObject
{
    Q_OBJECT
    Q_PROPERTY( int id READ id )
    Q_PROPERTY( int index READ index )
    Q_PROPERTY( QString title READ title )
    Q_PROPERTY( QString album READ album )
    Q_PROPERTY( QString artist READ artist )
    Q_PROPERTY( QString albumartist READ albumartist )
    Q_PROPERTY( int track READ track )
    Q_PROPERTY( int disc READ disc )
    Q_PROPERTY( QString pretty_year READ pretty_year )
    Q_PROPERTY( QString genre READ genre )
    Q_PROPERTY( int playcount READ playcount )
    Q_PROPERTY( int prety_length READ prety_length )
    Q_PROPERTY( QByteArray art READ art )
    Q_PROPERTY( int length READ length )
    Q_PROPERTY( bool is_local READ is_local )
    Q_PROPERTY( QString filename READ filename )
    Q_PROPERTY( int file_size READ file_size )
    Q_PROPERTY( float rating READ rating )
    Q_PROPERTY( QString url READ url )
    Q_PROPERTY( QString art_automatic READ art_automatic )
    Q_PROPERTY( QString art_manual READ art_manual )
    Q_PROPERTY( SongType type READ type )

public:
    explicit Song(QObject *parent = 0);
    Song(const pb::remote::SongMetadata& songData);
    ~Song();

public:

    enum SongType {
        UNKNOWN = 0,
        ASF = 1,
        FLAC = 2,
        MP4 = 3,
        MPC = 4,
        MPEG = 5,
        OGGFLAC = 6,
        OGGSPEEX = 7,
        OGGVORBIS = 8,
        AIFF = 9,
        WAV = 10,
        TRUEAUDIO = 11,
        CDDA = 12,
        OGGOPUS = 13,
        STREAM = 99
    };

    Q_ENUMS(SongType)

public:
    int id() { return m_id; }
    int index() { return m_index; }
    QString title() { return m_title; }
    QString album() { return m_album; }
    QString artist() { return m_artist; }
    QString albumartist() { return m_albumartist; }
    int track() { return m_track; }
    int disc() { return m_disc; }
    QString pretty_year() { return m_pretty_year; }
    QString genre() { return m_genre; }
    int playcount() { return m_playcount; }
    int prety_length() { return m_pretty_length; }
    QByteArray art() { return m_art; }
    int length() { return m_length; }
    bool is_local() { return m_is_local; }
    QString filename() { return m_filename; }
    int file_size() { return m_file_size; }
    float rating() { return m_rating; }
    QString url() { return m_url; }
    QString art_automatic() { return m_art_automatic; }
    QString art_manual() { return m_art_manual; }
    SongType type() { return m_type; }

    int m_id; // unique id of the song
    int m_index; // Index of the current row of the active playlist
    QString m_title;
    QString m_album;
    QString m_artist;
    QString m_albumartist;
    int m_track;
    int m_disc;
    QString m_pretty_year;
    QString m_genre;
    int m_playcount;
    int m_pretty_length;
    QByteArray m_art;
    int m_length;
    bool m_is_local;
    QString m_filename;
    int m_file_size;
    float m_rating; // 0 (0 stars) to 1 (5 stars)
    QString m_url;
    QString m_art_automatic;
    QString m_art_manual;
    SongType m_type;

};

#endif // SONG_H
