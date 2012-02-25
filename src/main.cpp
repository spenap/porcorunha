#include "controller.h"

#include <QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeView>
#include <QDeclarativeEngine>
#include <QDesktopServices>
#ifndef QT_SIMULATOR
    #include <MDeclarativeCache>
#endif

Q_DECL_EXPORT
int main(int argc, char *argv[])
{
    QApplication* app;
    QDeclarativeView* view;

#ifndef QT_SIMULATOR
    app = MDeclarativeCache::qApplication(argc, argv);
    view = MDeclarativeCache::qDeclarativeView();
#else
    app = new QApplication(argc, argv);
    view = new QDeclarativeView;
#endif

    app->setApplicationName("PorCorunha");
    app->setOrganizationDomain("com.simonpena");
    app->setOrganizationName("simonpena");

    view->engine()->setOfflineStoragePath(
                QDesktopServices::storageLocation(QDesktopServices::DataLocation));

    QDeclarativeContext* context = view->rootContext();
    Controller* controller = new Controller(context);

    view->setSource(QUrl("qrc:/qml/main.qml"));
    view->showFullScreen();

    int result = app->exec();

    delete controller;
    delete view;
    delete app;

    return result;
}
