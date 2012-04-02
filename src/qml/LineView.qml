import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.location 1.2
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha
import 'storage.js' as Storage
import 'util.js' as Util

Page {
    id: lineView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
        ToolButton {
            id: flipIcon
            anchors.centerIn: parent
            text: flipable.flipped ? 'Ver en lista' : 'Ver en mapa'
            onClicked: flipable.flipped = !flipable.flipped
        }
    }

    property int lineCode: 0
    property string lineName: ''
    property string description: ''
    property string direction: 'GO'

    property bool loading: false
    property variant cachedResponse: { 'GO': '', 'RETURN': '' }

    property MapView mapView

    Component.onCompleted: {
        loading = true
        var mapComponent = Qt.createComponent('MapView.qml')
        mapView = mapComponent.createObject(mapParent,
                                            {
                                                drawLandmarks: false,
                                                drawPolyline: true,
                                                landmarksModel: localModel,
                                                interactive: true,
                                                fullscreen: false
                                            })
        mapView.anchors.fill = mapParent
        var stops = Storage.loadStopsByLine({ direction: direction, lineCode: lineCode })
        if (stops.length === 0) {
            asyncWorker.sendMessage({ url: PorCorunha.moveteAPI.show_line(lineCode, direction) })
        } else {
            for (var i = 0; i < stops.length; i ++) {
                localModel.append(stops[i])
            }
            loading = false
            mapView.fitContentInMap()
        }
    }

    Component.onDestruction: {
        if (mapView) {
            mapView.destroy()
        }
    }

    function getDestination(direction) {
        var destinationTokens = description.split('-')
        return direction === 'GO' ?
                    destinationTokens[1] :
                    destinationTokens[0]
    }

    onDirectionChanged: {
        localModel.clear()
        var stops = Storage.loadStopsByLine({ direction: direction, lineCode: lineCode })
        if (stops.length !== 0) {
            for (var i = 0; i < stops.length; i ++) {
                localModel.append(stops[i])
            }
            mapView.fitContentInMap()
        } else if (!cachedResponse[direction]) {
            loading = true
            asyncWorker.sendMessage({ url: PorCorunha.moveteAPI.show_line(lineCode, direction) })
        } else {
            remoteModel.xml = cachedResponse[direction]
        }
    }

    Header { id: header }

    Label {
        id: lineLabel
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }
        text: 'Línea ' + lineName + ': ' + description
        platformStyle: LabelStyle {
            fontFamily: Constants.FONT_FAMILY
            fontPixelSize: Constants.FONT_XLARGE
        }
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    Label {
        id: directionLabel
        anchors {
            top: lineLabel.bottom
            left: parent.left
            topMargin: Constants.DEFAULT_MARGIN
            leftMargin: Constants.DEFAULT_MARGIN
        }
        text: 'Dirección: ' + getDestination(direction)
        platformStyle: LabelStyle {
            fontFamily: Constants.FONT_FAMILY_LIGHT
        }
    }

    ButtonRow {
        id: directionFilter
        anchors {
            top: directionLabel.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }

        Button {
            id: directionGO
            text: 'Ida'
            onClicked: {
                direction = 'GO'
            }
        }

        Button {
            id: directionRETURN
            text: 'Vuelta'
            onClicked: {
                direction = 'RETURN'
            }
        }
    }

    XmlListModel {
        id: remoteModel
        query: '/line/stop'

        XmlRole { name: 'code'; query: '@code/string()' }
        XmlRole { name: 'name'; query: '@name/string()' }
        XmlRole { name: 'lat'; query: '@lat/number()' }
        XmlRole { name: 'lng'; query: '@lng/number()' }
        XmlRole { name: 'position'; query: '@position/string()' }

        onStatusChanged: {
            if (status === XmlListModel.Ready &&
                    remoteModel.count !== 0) {
                for (var i = 0; i < remoteModel.count; i ++) {
                    var stop = new Util.BusStop(remoteModel.get(i).code,
                                                remoteModel.get(i).name,
                                                remoteModel.get(i).lat,
                                                remoteModel.get(i).lng,
                                                remoteModel.get(i).position)
                    localModel.append(stop)
                    if (!inSimulator) {
                        asyncWorker.sendMessage({
                                                    action: Constants.SAVE_STOP_LINE_ACTION,
                                                    line: {
                                                        code: lineCode,
                                                        direction: direction
                                                    },
                                                    stop: stop
                                                })
                    }
                }
                remoteModel.xml = ''
                mapView.fitContentInMap()
            }
        }
    }

    ListModel {
        id: localModel
    }

    Flipable {
        id: flipable
        property bool flipped: false

        anchors {
            top: directionFilter.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Constants.DEFAULT_MARGIN
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }

        front: ExtendedListView {
            anchors.fill: parent
            model: localModel
            loading: lineView.loading
            onClicked: {
                appWindow.pageStack.push(stopView,
                                         {
                                             stopCode: entry.code,
                                             stopName: entry.title,
                                             stopLat: entry.lat,
                                             stopLon: entry.lng
                                         })
            }
        }
        back: Item {
            id: mapParent
            anchors.fill: parent
        }

        transform: Rotation {
            id: rotation
            origin { x: flipable.width/2; y: flipable.height/2 }
            axis { z: 0; x: 0; y: 1 }
            angle: 0
        }

        states: State {
            name: 'back'
            when: flipable.flipped
            PropertyChanges { target: rotation; angle: 180 }
        }

        transitions: Transition {
            NumberAnimation { target: rotation; property: 'angle'; duration: 800 }
        }
    }

    function handleResponse(messageObject) {
        loading = false
        var response = {
            'GO': cachedResponse['GO'],
            'RETURN': cachedResponse['RETURN']
        }

        response[direction] = messageObject.response
        cachedResponse = response
        remoteModel.xml = cachedResponse[direction]
    }

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            handleResponse(messageObject)
        }
    }
}
