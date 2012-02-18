TEMPLATE = app
QT += declarative
CONFIG += meegotouch
TARGET = "porcorunha"
DEPENDPATH += .
INCLUDEPATH += .

HEADERS +=

SOURCES += \
    main.cpp

RESOURCES += \
    res.qrc

OTHER_FILES += \
    qml/main.qml \
    qml/LinesModel.qml \
    qml/StopsModel.qml \
    qml/StopsView.qml \
    qml/MainView.qml \
    qml/LinesView.qml \
    qml/StopView.qml \
    qml/LineView.qml \
    qml/constants.js \
    qml/Header.qml \
    qml/SearchView.qml \
    qml/workerscript.js \
    qml/porcorunha.js

unix {
    isEmpty(PREFIX) {
        PREFIX = /usr
    }
    BINDIR = $$PREFIX/bin
    DATADIR =$$PREFIX/share

    DEFINES += DATADIR=\\\"$$DATADIR\\\" PKGDATADIR=\\\"$$PKGDATADIR\\\"

    INSTALLS += target desktop icon64

    target.path =$$BINDIR

    desktop.path = $$DATADIR/applications
    desktop.files += $${TARGET}.desktop

    icon64.path = $$DATADIR/icons/hicolor/64x64/apps
    icon64.files += ../data/64x64/$${TARGET}.png
}
