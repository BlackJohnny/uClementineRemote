#include "filedownloader.h"
#include <QDataStream>
#include <QDebug>

FileDownloader* FileDownloader::m_instance = NULL;

FileDownloader::FileDownloader()
{
    m_downloadStatus = DownloadIdle;
}

FileDownloader::DownloadStatus FileDownloader::getDownloadStatus()
{
    if(!m_instance)
        m_instance = new FileDownloader();

    return m_instance->m_downloadStatus;
}

void FileDownloader::newDownloadRequested()
{
    if(!m_instance)
        m_instance = new FileDownloader();

    m_instance->m_downloadStatus = DownloadWaiting;
}

void FileDownloader::SetDownloadDirectory(QString destinationDirectory)
{
    if(!m_instance)
        m_instance = new FileDownloader();

    m_instance->m_destinationDirectory = destinationDirectory;
}

void FileDownloader::RegisterDownload(int playListId, QString songUrl)
{
    if(!m_instance)
        m_instance = new FileDownloader();

    return m_instance->RegisterDownloadInternal(playListId, songUrl);
}

void FileDownloader::RegisterDownloadInternal(int playListId, QString songUrl)
{
    QMutexLocker locker(&m_queueReadWriteLock);

    m_downloadQueue[songUrl] = playListId;
}

bool FileDownloader::GetNextDownload(int& playListId, QString& songUrl)
{
    if(!m_instance)
        m_instance = new FileDownloader();

    return m_instance->GetNextDownloadInternal(playListId, songUrl);
}

bool FileDownloader::GetNextDownloadInternal(int& playListId, QString& songUrl)
{
    QMutexLocker locker(&m_queueReadWriteLock);

    if(!m_downloadQueue.isEmpty())
    {
        songUrl = m_downloadQueue.firstKey();
        playListId = m_downloadQueue.first();
        return true;
    }

    return false;
}

void FileDownloader::StartDownload(const pb::remote::SongMetadata& songMetaData)
{
    if(!m_instance)
        m_instance = new FileDownloader();

    if(m_instance->m_file.isOpen())
        m_instance->m_file.close();

    m_instance->m_currentSongUrl = songMetaData.url().c_str();
    m_instance->m_file.setFileName(m_instance->m_destinationDirectory + songMetaData.filename().c_str());
    m_instance->m_file.open(QIODevice::WriteOnly);
}

void FileDownloader::Destroy()
{
    if(m_instance)
    {
        delete m_instance;
        m_instance = NULL;
    }
}

FileDownloader::DownloadStatus FileDownloader::SaveFileChunk(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize, const pb::remote::SongMetadata& songMetaData)
{
    if(!m_instance)
        m_instance = new FileDownloader();

    return m_instance->SaveFileChunkInternal(fileNumber, chunkNumber, chunkCount, chunkData, chunkSize, songMetaData);
}

FileDownloader::DownloadStatus FileDownloader::SaveFileChunkInternal(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize, const pb::remote::SongMetadata& songMetaData)
{
    if(chunkNumber == 0)
    {
        StartDownload(songMetaData);
        m_downloadStatus = FileDownloader::DownloadStarted;
        return m_downloadStatus;
    }

    m_file.write(chunkData, chunkSize);

    // If this was the last chunk we close the file
    if(chunkCount == chunkNumber)
    {
        QMutexLocker locker(&m_queueReadWriteLock);
        m_downloadQueue.remove(m_currentSongUrl);
        m_file.close();
        m_downloadStatus = FileDownloader::DownloadCompleted;
        return m_downloadStatus;
    }

    m_downloadStatus = FileDownloader::DownloadInProgress;
    return m_downloadStatus;
}
