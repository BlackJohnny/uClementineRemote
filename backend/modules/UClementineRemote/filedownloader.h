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
    static void registerDownload(int playListId, QString songUrl);
    static void startDownload(const pb::remote::SongMetadata& songMetaData);
    static bool getNextDownload(int& playListId, QString& songUrl);
    static FileDownloader::DownloadStatus getDownloadStatus();
    static bool isDownloadQueueEmpty();
    static int downloadQueueSize();
    static void setDownloadDirectory(QString destinationDirectory);
    static void newDownloadRequested();

    static void Destroy();

    static FileDownloader::DownloadStatus saveFileChunk(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize, const pb::remote::SongMetadata& songMetaData);

private:
    void registerDownloadInternal(int playListId, QString songUrl);
    FileDownloader::DownloadStatus saveFileChunkInternal(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize, const pb::remote::SongMetadata& songMetaData);
    bool getNextDownloadInternal(int& playListId, QString& songUrl);
    bool isDownloadQueueEmptyInternal();
    int downloadQueueSizeInternal();

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
