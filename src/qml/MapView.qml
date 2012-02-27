import QtQuick 1.1
import QtMobility.location 1.2
import com.nokia.meego 1.0
import 'constants.js' as Constants

// Pinch zoom behaviour from
// http://developer.qt.nokia.com/wiki/QML_Maps_with_Pinch_Zoom

Item {
    id: mapComponent
    height: Constants.MAP_AREA_HEIGHT

    property Coordinate mapCenter: Coordinate { }
    property Coordinate lowerLeftCoordinate: Coordinate { }
    property Coordinate upperRightCoordinate: Coordinate { }
    property real distance: 1000
    property bool startCentered: false
    property bool drawPolyline: false
    property bool drawLandmarks: true

    property string addressText: ''

    property ListModel landmarksModel

    property bool interactive: false
    property bool fullscreen: interactive

    signal clicked()

    function fitContentInMap() {
        var minLat = 100, minLon = 100
        var maxLat = -100, maxLon = -100

        for (var i = 0; i < landmarksModel.count; i ++) {
            minLat = Math.min(minLat, landmarksModel.get(i).lat)
            minLon = Math.min(minLon, landmarksModel.get(i).lon)
            maxLat = Math.max(maxLat, landmarksModel.get(i).lat)
            maxLon = Math.max(maxLon, landmarksModel.get(i).lon)
        }
        mapCenter.latitude = (minLat + maxLat) / 2
        mapCenter.longitude  = (minLon + maxLon) / 2

        lowerLeftCoordinate.latitude = minLat
        lowerLeftCoordinate.longitude = minLon

        upperRightCoordinate.latitude = maxLat
        upperRightCoordinate.longitude = maxLon

        distance = lowerLeftCoordinate.distanceTo(upperRightCoordinate)
        map.center = mapCenter
    }

    function getZoomLevel(distance) {

        if (distance > 3500) {
            return 13
        } else if (distance > 2000) {
            return 13.5
        } else if (distance > 1500) {
            return 14
        } else if (distance > 1000) {
            return 14.5
        } else if (distance > 500) {
            return 15
        } else if (distance > 250) {
            return 15.5
        } else {
            return 16
        }
    }

    Map {
        id: map
        plugin: Plugin { name: 'nokia' }
        connectivityMode: Map.HybridMode
        size {
            width: parent.width
            height: parent.height
        }
        smooth: true
        zoomLevel: getZoomLevel(distance)
        center: startCentered ?
                    mapCenter :
                    positionSource.position.coordinate

        MapImage {
            coordinate: mapCenter
            source: 'qrc:/resources/icon-s-bus-stop.png'
            visible: startCentered
        }

        MapCircle {
            center: positionSource.position.coordinate
            radius: 450 / map.zoomLevel
            color: '#80ff0000'
            border {
                width: 1
                color: 'red'
            }
        }

        MapCircle {
            center: positionSource.position.coordinate
            radius: 750 / map.zoomLevel
            color: 'transparent'
            border {
                width: 2
                color: 'red'
            }
        }

        MapPolyline {
            id: mapPolyline
            border {
                color: 'red'
                width: 4
            }
        }

        MapMouseArea {
            anchors.fill: parent
            onClicked: mapComponent.clicked()
        }
    }

    PinchArea {
        id: pinchArea
        enabled: interactive
        anchors.fill: parent

        property double initialZoom

        function calcZoomDelta(zoom, percent) {
            return zoom + 3 * Math.log(percent)
        }

        onPinchStarted: {
            initialZoom = map.zoomLevel
        }

        onPinchUpdated: {
            map.zoomLevel = calcZoomDelta(initialZoom, pinch.scale)
        }

        onPinchFinished: {
            map.zoomLevel = calcZoomDelta(initialZoom, pinch.scale)
        }
    }

    MouseArea {
        id: mouseArea
        enabled: interactive

        property bool isPanning: false
        property int lastX: -1
        property int lastY: -1

        anchors.fill : parent

        onPressed: {
            isPanning = true
            lastX = mouse.x
            lastY = mouse.y
        }

        onReleased: {
            isPanning = false
        }

        onPositionChanged: {
            if (isPanning) {
                var dx = mouse.x - lastX
                var dy = mouse.y - lastY
                map.pan(-dx, -dy)
                lastX = mouse.x
                lastY = mouse.y
            }
        }

        onCanceled: {
            isPanning = false;
        }
    }

    BorderImage {
        id: border
        source: 'qrc:/resources/round-corners-shadow.png'
        anchors.fill: parent
        border.left: 18; border.top: 18
        border.right: 18; border.bottom: 18
        visible: !fullscreen
    }

    Repeater {
        model: landmarksModel
        delegate: Component {
            MapImage {
                coordinate: Coordinate {
                    latitude: model.lat
                    longitude: model.lon
                }
                source: 'qrc:/resources/icon-s-bus-stop.png'
            }
        }

        onItemAdded: {
            if (drawLandmarks) {
                map.addMapObject(item)
            }
            if (drawPolyline) {
                mapPolyline.addCoordinate(item.coordinate)
            }
        }

        onItemRemoved: {
            if (drawLandmarks) {
                map.removeMapObject(item)
            }
            if (drawPolyline &&
                    !(inSimulator && mapPolyline.path.length === 1)) {
                mapPolyline.removeCoordinate(item.coordinate)
            }
        }
    }

    Rectangle {
        id: addressRectangle
        width: addressLabel.implicitWidth + Constants.DEFAULT_MARGIN
        height: 40
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            margins: Constants.DEFAULT_MARGIN / 2
        }
        color: '#80808080'
        radius: 10
        border {
            color: 'darkgrey'
            width: 2
        }
        visible: addressText

        Label {
            id: addressLabel
            anchors.centerIn: parent
            text: addressText
            color: 'white'
        }
    }
}
