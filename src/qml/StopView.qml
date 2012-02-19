import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.location 1.2
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha

Page {
    id: stopView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

    property int stopCode: 0
    property string stopName: ''
    property real stopLat: 0.0
    property real stopLon: 0.0
    property Coordinate coordinate: Coordinate {
        latitude: stopLat
        longitude: stopLon
    }

    property bool loading: false
    property string cachedResponse: ''

    property string linesQuery: '/lines/line'
    property string distancesQuery: '/stop/line'
    property string modelQuery: distancesQuery

    Component.onCompleted: {
        loading = true
        asyncWorker.sendMessage({
                                    url: PorCorunha.moveteAPI.get_distances(stopCode)
                                })
    }

    Header { id: header }

    MapView {
        id: mapArea
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }
        addressText: stopName
        mapCenter: stopView.coordinate
        startCentered: true
        distance: 100
    }

    XmlListModel {
        id: stopModel
        xml: cachedResponse
        query: modelQuery

        XmlRole { name: 'code'; query: '@code/string()' }
        XmlRole { name: 'title'; query: '@name/string()' }
        XmlRole { name: 'direction'; query: '@direction/string()' }
        XmlRole { name: 'subtitle'; query: '@directionDescription/string()' }
        XmlRole { name: 'description'; query: '@description/string()' }
    }

    ExtendedListView {
        anchors {
            top: mapArea.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        loading: stopView.loading
        elvModel: stopModel
        onClicked: {
            detailedView.show(entry)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: detailedView.hide()
        enabled: detailedView.visible
    }

    Item {
        id: detailedView
        height: parent.height / 2
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        visible: false

        property variant modelEntry: ({ })
        property string detailsModelSource: ''

        function show(modelEntry) {
            detailedView.visible = true
            detailedView.modelEntry = modelEntry
        }

        function hide() {
            detailedView.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: 'white'
        }

        Label {
            id: lineLabel
            anchors {
                top: parent.top
                left: parent.left
                topMargin: Constants.DEFAULT_MARGIN
                leftMargin: Constants.DEFAULT_MARGIN
            }
            text: 'Línea ' + detailedView.modelEntry.title + ': ' + detailedView.modelEntry.description
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
            text: 'Dirección: ' + detailedView.modelEntry.subtitle
            platformStyle: LabelStyle {
                fontFamily: Constants.FONT_FAMILY_LIGHT
            }
        }

        ListView {
            id: detailsList
            anchors.top: directionLabel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Constants.DEFAULT_MARGIN
            delegate: ListDelegate { }
            model: XmlListModel {

                xml: !detailedView.modelEntry.code ? '' : cachedResponse
                query: '/stop/line[@code=' + detailedView.modelEntry.code + ']/vehicle'

                XmlRole { name: 'code'; query: '@code/string()' }
                XmlRole { name: 'title'; query: '@time/string()' }
                XmlRole { name: 'subtitle'; query: '@distance/string()' }
            }
        }
    }

    function handleResponse(messageObject) {
        cachedResponse = messageObject.response
        if (!cachedResponse &&
                messageObject.url === PorCorunha.moveteAPI.get_distances(stopCode)) {
            modelQuery = linesQuery
            asyncWorker.sendMessage({ url: PorCorunha.moveteAPI.get_lines_by_stop(stopCode, 1, 20)})
        }
        loading = false
    }

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            handleResponse(messageObject)
        }
    }
}
