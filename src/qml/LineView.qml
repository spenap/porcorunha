import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.location 1.2
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha

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
    property real meanLongitude: 0
    property real meanLatitude: 0
    property real minLongitude: 0
    property real maxLongitude: 0
    property real minLatitude: 0
    property real maxLatitude: 0
    property variant lineCenter: Coordinate {
        latitude: meanLatitude
        longitude: meanLongitude
    }
    property variant minCoordinate: Coordinate {
        latitude: minLatitude
        longitude: minLongitude
    }
    property variant maxCoordinate: Coordinate {
        latitude: maxLatitude
        longitude: maxLongitude
    }
    property real distance: 0

    Component.onCompleted: {
        loading = true
        asyncWorker.sendMessage({
                                    url: PorCorunha.moveteAPI.show_line(lineCode, direction)
                                })
    }

    function getDestination(direction) {
        var destinationTokens = description.split('-')
        return direction === 'GO' ?
                    destinationTokens[1] :
                    destinationTokens[0]
    }

    onDirectionChanged: {
        if (!cachedResponse[direction]) {
            loading = true
            asyncWorker.sendMessage({
                                        url: PorCorunha.moveteAPI.show_line(lineCode, direction)
                                    })
        }
    }

    Header { id: header }

    Label {
        id: lineLabel
        anchors {
            top: header.bottom
            left: parent.left
            topMargin: Constants.DEFAULT_MARGIN
            leftMargin: Constants.DEFAULT_MARGIN
        }
        text: 'Línea ' + lineName + ': ' + description
        platformStyle: LabelStyle {
            fontFamily: Constants.FONT_FAMILY
            fontPixelSize: Constants.FONT_XLARGE
        }
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
        id: stopsModel
        xml: cachedResponse[direction]
        query: '/line/stop'

        XmlRole { name: 'code'; query: '@code/string()' }
        XmlRole { name: 'title'; query: '@name/string()' }
        XmlRole { name: 'lat'; query: '@lat/number()' }
        XmlRole { name: 'lng'; query: '@lng/number()' }
        XmlRole { name: 'position'; query: '@position/string()' }

        onStatusChanged: {
            if (status === XmlListModel.Ready &&
                    stopsModel.count !== 0) {
                var lat = 0, lon = 0
                var minLat = 100, minLon = 100
                var maxLat = -100, maxLon = -100
                for (var i = 0; i < stopsModel.count; i ++) {
                    lat += stopsModel.get(i).lat
                    lon += stopsModel.get(i).lng

                    minLat = Math.min(minLat, stopsModel.get(i).lat)
                    minLon = Math.min(minLon, stopsModel.get(i).lng)
                    maxLat = Math.max(maxLat, stopsModel.get(i).lat)
                    maxLon = Math.max(maxLon, stopsModel.get(i).lng)
                }
                meanLatitude = lat / stopsModel.count
                meanLongitude  = lon / stopsModel.count
                minLatitude = minLat; minLongitude = minLon
                maxLatitude = maxLat; maxLongitude = maxLon

                distance = minCoordinate.distanceTo(maxCoordinate)
            }
        }
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

    front: Item {
        anchors.fill: parent

        ScrollDecorator {
            flickableItem: stopsList
            anchors.rightMargin: -Constants.DEFAULT_MARGIN
        }

        ListView {
            id: stopsList
            anchors.fill: parent
            clip: true
            model: stopsModel

            delegate: ListDelegate {
                MoreIndicator {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: {
                    appWindow.pageStack.push(stopView,
                                             {
                                                 stopCode: model.code,
                                                 stopName: model.title,
                                                 stopLat: model.lat,
                                                 stopLon: model.lng
                                             })
                }
            }
        }
    }
    back: Item {
        anchors.fill: parent

        Map {
            id: map
            plugin : Plugin {
                name : 'nokia'
            }
            size {
                width: parent.width
                height: parent.height
            }
            zoomLevel: distance > 3500 ? 13 : 14
            center: lineCenter

            MapPolyline {
                id: busLinePolyline
                border {
                    color: 'red'
                    width: 4
                }
            }
        }

        Repeater {
            model: stopsModel
            delegate: Component {
                MapImage {
                    coordinate: Coordinate {
                        latitude: model.lat
                        longitude: model.lng
                    }
                    source: 'qrc:/resources/icon-s-bus-stop.png'
                }
            }

            onItemAdded: {
                busLinePolyline.addCoordinate(item.coordinate)
//                map.addMapObject(item)
            }
            onItemRemoved: {
                busLinePolyline.removeCoordinate(item.coordinate)
//                map.removeMapObject(item)
            }
        }
    }

    transform: Rotation {
             id: rotation
             origin {
                 x: flipable.width/2
                 y: flipable.height/2
             }
             axis {
                 // set axis.y to 1 to rotate around y-axis
                 z: 0
                 x: 0
                 y: 1
             }
             // the default angle
             angle: 0
         }

         states: State {
             name: "back"
             PropertyChanges { target: rotation; angle: 180 }
             when: flipable.flipped
         }

         transitions: Transition {
             NumberAnimation { target: rotation; property: "angle"; duration: 800 }
         }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: visible
        visible: loading
        platformStyle: BusyIndicatorStyle {
            size: 'large'
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
    }

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            handleResponse(messageObject)
        }
    }
}
