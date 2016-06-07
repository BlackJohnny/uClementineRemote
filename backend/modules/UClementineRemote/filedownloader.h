#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QString>
#include <QFile>

#include "remotecontrolmessages.pb.h"

class FileDownloader
{
public:
    enum DownloadStatus
    {
        DownloadError,
        DownloadInProgress,
        DownloadCompleted
    };

public:
    static void Init(QString destinationDirectory, const pb::remote::SongMetadata& songMetaData);
    static void Destroy();

    static bool SaveFileChunk(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize);

private:
    bool SaveFileChunkInternal(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize);

private:
    FileDownloader();

    static FileDownloader* m_instance;

    QFile m_file;
    int m_currentFileNumber;
    QString m_destinationDirectory;
};

#endif // FILEDOWNLOADER_H
