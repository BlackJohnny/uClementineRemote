#include "filedownloader.h"
#include <QDataStream>

FileDownloader* FileDownloader::m_instance = NULL;

FileDownloader::FileDownloader() :
    m_currentFileNumber(-1)
{
}

void FileDownloader::Init(QString destinationDirectory, const pb::remote::SongMetadata& songMetaData)
{
    if(!m_instance)
        m_instance = new FileDownloader();

    m_instance->m_destinationDirectory = destinationDirectory;

    if(m_instance->m_file.isOpen())
        m_instance->m_file.close();

    m_instance->m_file.setFileName(destinationDirectory + songMetaData.filename().c_str());
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

bool FileDownloader::SaveFileChunk(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize)
{
    if(!m_instance)
        return false;

    return m_instance->SaveFileChunkInternal(fileNumber, chunkNumber, chunkCount, chunkData, chunkSize);
}

bool FileDownloader::SaveFileChunkInternal(int fileNumber, int chunkNumber, int chunkCount, const char* chunkData, int chunkSize)
{
    m_file.write(chunkData, chunkSize);

    // If this was the last chunk we close the file
    if(chunkCount == chunkNumber)
    {
        m_file.close();
        return false;
    }

    return true;
}
