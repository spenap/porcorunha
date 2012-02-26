import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2

PageStackWindow {
    id: appWindow

    initialPage: mainView
    showStatusBar: appWindow.inPortrait

    property string currentAddress: 'Actualizando...'
    property int currentAddressLookupId: 0

    Component.onCompleted: {
        if (theme.colorScheme) {
            // TODO: Set a suitable color scheme (available in Qt Components master)
            // http://fiferboy.blogspot.com/2011/08/qml-colour-themes-in-harmattan.html
            theme.colorScheme = 'darkRed'
        }
    }

    PositionSource {
        id: positionSource
        active: inSimulator ? true : platformWindow.active

        onPositionChanged: {
            currentAddressLookupId =
                    controller.lookup(positionSource.position.coordinate.latitude,
                                      positionSource.position.coordinate.longitude)
        }
    }

    Connections {
        target: controller
        onAddressResolved: handleAddressResolved(lookupId, address)
    }

    MainView { id: mainView }

    function handleAddressResolved(lookupId, address) {
        if (currentAddressLookupId === lookupId) {
            appWindow.currentAddress = address
        }
    }
}
