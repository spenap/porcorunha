#include "controller.h"

#include <QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeView>
#include <QDeclarativeEngine>
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
