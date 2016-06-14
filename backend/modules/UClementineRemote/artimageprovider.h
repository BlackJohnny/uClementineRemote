#ifndef ARTIMAGEPROVIDER_H
#define ARTIMAGEPROVIDER_H
#include <QQuickImageProvider>

class ArtImageProvider : public QQuickImageProvider
{
public:
    QImage requestImage(const QString &id, QSize *size, const QSize& requestedSize);
    static ArtImageProvider* getInstance();
    static void setCurrentImageData(const QByteArray& imageData);

protected:
    ArtImageProvider();
    QByteArray m_currentArt;

    static ArtImageProvider* m_instance;
};

#endif // ARTIMAGEPROVIDER_H
