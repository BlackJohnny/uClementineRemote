#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QString>
#include <QFile>
#include <QMutex>
#include <QMutexLocker>
#include <QMap>

#include "remotecontrolmessages.pb.h"

class FileDownloader
{
public:
    enum DownloadStatus
    {
        DownloadError,
        DownloadIdle,
        DownloadWaiting,
        DownloadStarted,
        DownloadInProgress,
        DownloadCompleted
    };

public:
    static void RegisterDownload(int playListId, QString songUrl);
    static void StartDownload(const pb::remote::SongMetadata& songMetaData);
    static bool GetNextDownload(int& playListId, QString& songUrl);
    static FileDownloader::DownloadStatus getDownloadStatus();
    static void SetDownloadDirectory(QString destinationDirectory);
    static void newDownloadRequested();

    static void Destroy();

    static FileDownloader::DownloadStatus SaveFileChunk(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize, const pb::remote::SongMetadata& songMetaData);

private:
    void RegisterDownloadInternal(int playListId, QString songUrl);
    FileDownloader::DownloadStatus SaveFileChunkInternal(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize, const pb::remote::SongMetadata& songMetaData);
    bool GetNextDownloadInternal(int& playListId, QString& songUrl);

private:
    FileDownloader();

    static FileDownloader* m_instance;

    QFile m_file;
    QString m_currentSongUrl;
    DownloadStatus m_downloadStatus;
    QString m_destinationDirectory;
    QMutex m_queueReadWriteLock;
    QMap<QString, int> m_downloadQueue;
};

#endif // FILEDOWNLOADER_H
