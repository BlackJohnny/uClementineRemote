#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QString>

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
    static void Init(int fileNumbers, QString destinationPath);
    static FileDownloader::DownloadStatus SaveFileChunk(int fileNumber, int fileChunk, int fileSize, void* chunk, int chunkSize, const pb::remote::SongMetadata& songMetaData);

private:
    FileDownloader();

    static FileDownloader* m_instance;
};

#endif // FILEDOWNLOADER_H
