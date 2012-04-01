import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2

PageStackWindow {
    id: appWindow

    initialPage: mainView
    showStatusBar: appWindow.inPortrait

    Component.onCompleted: {
        if (theme.colorScheme) {
            // TODO: Set a suitable color scheme (available in Qt Components master)
            // http://fiferboy.blogspot.com/2011/08/qml-colour-themes-in-harmattan.html
            theme.colorScheme = 'darkGreen'
        }
    }

    PositionSource {
        id: positionSource
        active: inSimulator || platformWindow.active
    }

    MainView { id: mainView }
}
