#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <jsonfile.h>
#include <mpvobject.h>
#include "aes.h"

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);
    std::setlocale(LC_NUMERIC, "C");
    qmlRegisterType<MpvObject>("mpvPlayer", 1, 0, "MpvObject");
    QQmlApplicationEngine engine;
    qmlRegisterType<AES>("AesCrypt", 1, 0, "AES");
    qmlRegisterType<JsonFile>("JsonFile", 1, 0, "JsonFile");
    const QUrl url(u"qrc:/qml/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
