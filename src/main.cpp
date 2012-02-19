#include "controller.h"

#include <QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeView>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;

    QDeclarativeContext* context = view.rootContext();
    Controller* controller = new Controller(context);

    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.showFullScreen();

    int result = app.exec();

    delete controller;

    return result;
}
