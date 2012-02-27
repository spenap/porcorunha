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
        ToolIcon {
            id: refreshIcon
            iconId: 'toolbar-refresh'
            onClicked: {
                cachedResponse = ''
                loading = true
                asyncWorker.sendMessage({ url: PorCorunha.moveteAPI.get_distances(stopCode) })
            }
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
    property string lastUpdate: ''

    Component.onCompleted: {
        loading = true
        asyncWorker.sendMessage({ url: PorCorunha.moveteAPI.get_distances(stopCode) })
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
        model: stopModel
        header: Label {
            anchors.horizontalCenter: parent.horizontalCenter
            platformStyle: LabelStyle {
                fontPixelSize: Constants.FONT_XXSMALL
                fontFamily: Constants.FONT_FAMILY_LIGHT
            }
            text: 'Última actualización: ' + stopView.lastUpdate
            horizontalAlignment: Text.AlignHCenter
            visible: stopView.lastUpdate !== ''
        }
        delegate: LocalListDelegate {
            response: cachedResponse
        }
    }

    function handleResponse(messageObject) {
        cachedResponse = messageObject.response
        if (!cachedResponse &&
                messageObject.url === PorCorunha.moveteAPI.get_distances(stopCode)) {
            modelQuery = linesQuery
            asyncWorker.sendMessage({ url: PorCorunha.moveteAPI.get_lines_by_stop(stopCode, 1, 20)})
        } else {
            stopView.lastUpdate = Qt.formatTime(new Date)
            loading = false
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
