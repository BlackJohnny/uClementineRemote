#include "artimageprovider.h"
#include <QDebug>

ArtImageProvider* ArtImageProvider::m_instance = NULL;

ArtImageProvider::ArtImageProvider() :
    QQuickImageProvider(QQmlImageProviderBase::Image),
    m_currentArt(NULL)
{

}

QImage ArtImageProvider::requestImage(const QString &id, QSize *size, const QSize& requestedSize)
{
    qDebug() << "Image provider: " << id << "size:" << requestedSize;

    QImage img = QImage::fromData(m_currentArt);

    size->setHeight(img.height());
    size->setWidth(img.width());

    return img;
}

ArtImageProvider* ArtImageProvider::getInstance()
{
    if(!m_instance)
        m_instance = new ArtImageProvider();

    return m_instance;
}

void ArtImageProvider::setCurrentImageData(const QByteArray& imageData)
{
    ArtImageProvider::getInstance()->m_currentArt.clear();
    ArtImageProvider::getInstance()->m_currentArt.append(imageData);
}
