QMAKEVERSION = $$[QMAKE_VERSION]
ISQT4 = $$find(QMAKEVERSION, ^[2-9])
isEmpty( ISQT4 ) {
error("Use the qmake include with Qt4.4 or greater, on Debian that is qmake-qt4");
}

TEMPLATE = subdirs
SUBDIRS  = src

OTHER_FILES += \
    README.md \
    COPYING \
    AUTHORS \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/porcorunha.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qtc_packaging/debian_harmattan/porcorunha.postrm \
    qtc_packaging/debian_harmattan/porcorunha.postinst
