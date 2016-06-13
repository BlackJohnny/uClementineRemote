#include <QtQml>
#include <QtQml/QQmlContext>
#include "backend.h"

#include "clementineproxy.h"
#include "playlists.h"
#include "playlist.h"
#include "song.h"
#include "artimageprovider.h"

#include "remotecontrolmessages.pb.h"

void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("UClementineRemote"));

    qmlRegisterType<ClementineProxy>(uri, 1, 0, "ClementineProxy");
    qmlRegisterType<PlayLists>(uri, 1, 0, "PlayLists");
    qmlRegisterType<PlayList>(uri, 1, 0, "PlayList");
    qmlRegisterType<Song>(uri, 1, 0, "Song");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QCoreApplication::setApplicationName("uclementineremote.blackjohnny");
    QCoreApplication::setOrganizationDomain("uclementineremote.blackjohnny");

    engine->addImageProvider("songArt", ArtImageProvider::getInstance());

    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
