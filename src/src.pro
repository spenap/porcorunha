TEMPLATE = app
QT += declarative
TARGET = "porcorunha"
DEPENDPATH += .
INCLUDEPATH += .

CONFIG += mobility

MOBILITY += location

# enable booster
CONFIG += qt-boostable qdeclarative-boostable

# booster flags
QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic

!simulator {
    LIBS += -lmdeclarativecache
}

HEADERS += \
    controller.h \
    reversegeocoder.h

SOURCES += \
    main.cpp \
    controller.cpp \
    reversegeocoder.cpp

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
    qml/Header.qml \
    qml/SearchView.qml \
    qml/MapView.qml \
    qml/ExtendedListView.qml \
    qml/LocalListDelegate.qml \
    qml/constants.js \
    qml/workerscript.js \
    qml/porcorunha.js \
    qml/storage.js \
    qml/util.js \
    TODO.txt

unix {
    isEmpty(PREFIX) {
        PREFIX = /opt/$${TARGET}
    }
    BINDIR = $$PREFIX/bin
    DATADIR =$$PREFIX/share

    DEFINES += DATADIR=\\\"$$DATADIR\\\" PKGDATADIR=\\\"$$PKGDATADIR\\\"

    INSTALLS += target desktop icon64 database splash

    target.path =$$BINDIR

    desktop.path = /usr/share/applications
    desktop.files += $${TARGET}.desktop

    icon64.path = /usr/share/icons/hicolor/64x64/apps
    icon64.files += ../data/icon-l-$${TARGET}.png

    database.path = $$DATADIR/
    database.files += ../data/bus-transportation.db
    database.files += ../data/bus-transportation.ini

    splash.path = $$DATADIR/
    splash.files += ../data/porcorunha-portrait-splash.png
}
