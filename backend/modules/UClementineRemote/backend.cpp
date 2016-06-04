#include <QtQml>
#include <QtQml/QQmlContext>
#include "backend.h"
#include "clementineproxy.h"
#include "remotecontrolmessages.pb.h"

void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("UClementineRemote"));

    qmlRegisterType<ClementineProxy>(uri, 1, 0, "ClementineProxy");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}

