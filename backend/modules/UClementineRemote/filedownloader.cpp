#include "filedownloader.h"

FileDownloader* FileDownloader::m_instance = NULL;

FileDownloader::FileDownloader()
{
}

void FileDownloader::Init(int fileNumbers, QString destinationPath)
{
}

FileDownloader::DownloadStatus FileDownloader::SaveFileChunk(int fileNumber, int fileChunk, int fileSize, void* chunk, int chunkSize, const pb::remote::SongMetadata& songMetaData)
{
    if(!m_instance)
        return DownloadError;

    return DownloadInProgress;
}
