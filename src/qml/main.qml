import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import 'constants.js' as Constants

PageStackWindow {
    id: appWindow

    initialPage: mainView
    showStatusBar: appWindow.inPortrait

    property variant mapComponent: undefined

    Component.onCompleted: {
        if (theme.colorScheme) {
            // TODO: Set a suitable color scheme (available in Qt Components master)
            // http://fiferboy.blogspot.com/2011/08/qml-colour-themes-in-harmattan.html
            theme.colorScheme = 'darkGreen'
        }
        asyncWorker.sendMessage({
                                    action: Constants.SINGLE_SHOT_ACTION
                                })
    }

    PositionSource {
        id: positionSource
        active: inSimulator || platformWindow.active
    }

    MainView { id: mainView }

    function createMapView(parent, args) {
        if (!mapComponent) {
            mapComponent = Qt.createComponent('MapView.qml')
        }
        var t1 = new Date()
        var mapView = mapComponent.createObject(parent, args)
        console.debug(new Date() - t1)
        mapView.anchors.fill = parent
        return mapView
    }

    Item {
        id: parentHelper
        visible: false
        height: 1; width: 1
    }

    function handleResponse(messageObject) {
        if (messageObject.action === Constants.SINGLE_SHOT_RESPONSE) {
            var map = createMapView(parentHelper, { })
            map.destroy()
        }
    }

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            handleResponse(messageObject)
        }
    }
}
