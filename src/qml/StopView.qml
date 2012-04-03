import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.location 1.2
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha
import 'storage.js' as Storage
import 'util.js' as Util

Page {
    id: stopView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
        ToolIcon {
            id: favoriteIcon
            iconId: favorite ? 'toolbar-favorite-mark' : 'toolbar-favorite-unmark'
            onClicked: {
                favorite = !favorite
                controller.setFavorite(stopCode, favorite)
            }
        }
        ToolIcon {
            id: refreshIcon
            iconId: 'toolbar-refresh'
            onClicked: {
                localModel.clear()
                cachedResponse = ''
                loading = true
                asyncWorker.sendMessage({
                                            action: Constants.REMOTE_FETCH_ACTION,
                                            url: PorCorunha.moveteAPI.get_distances(stopCode)
                                        })
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
    property bool liveInfo: true
    property string lastUpdate: '...'
    property string lastUpdateText: liveInfo ?
                                        ('Última actualización: ' + lastUpdate) :
                                        'Sin información de tiempos'
    property bool favorite: false

    property MapView mapArea

    Component.onCompleted: {
        loading = true
        favorite = controller.isFavorite(stopCode)
        asyncWorker.sendMessage({
                                    action: Constants.REMOTE_FETCH_ACTION,
                                    url: PorCorunha.moveteAPI.get_distances(stopCode)
                                })
        mapArea = createMapView(mapParent,
                                {
                                    addressText: stopName,
                                    mapCenter: stopView.coordinate,
                                    startCentered: true,
                                    distance: 100
                                })
    }

    Component.onDestruction: {
        if (mapArea) {
            mapArea.destroy()
        }
    }

    Header { id: header }

    Item {
        id: mapParent
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }
        height: Constants.MAP_AREA_HEIGHT
    }

    XmlListModel {
        id: remoteModel
        xml: cachedResponse
        query: modelQuery

        XmlRole { name: 'code'; query: '@code/string()' }
        XmlRole { name: 'name'; query: '@name/string()' }
        XmlRole { name: 'direction'; query: '@direction/string()' }
        XmlRole { name: 'directionDescription'; query: '@directionDescription/string()' }
        XmlRole { name: 'description'; query: '@description/string()' }

        onStatusChanged: {
            if (status === XmlListModel.Ready &&
                    remoteModel.count !== 0) {
                localModel.clear()
                for (var i = 0; i < remoteModel.count; i ++) {
                    var line = new Util.BusLine(remoteModel.get(i).code,
                                                remoteModel.get(i).name,
                                                remoteModel.get(i).direction,
                                                remoteModel.get(i).directionDescription,
                                                remoteModel.get(i).description,
                                                { subtitle: 'Dirección ' + remoteModel.get(i).directionDescription })
                    localModel.append(line)
                }
                loading = false
            }
        }
    }

    ListModel {
        id: localModel
    }

    ExtendedListView {
        anchors {
            top: mapParent.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        loading: stopView.loading
        model: localModel
        header: Label {
            anchors.horizontalCenter: parent.horizontalCenter
            platformStyle: LabelStyle {
                fontPixelSize: Constants.FONT_XXSMALL
                fontFamily: Constants.FONT_FAMILY_LIGHT
            }
            text: lastUpdateText
            horizontalAlignment: Text.AlignHCenter
        }
        delegate: LocalListDelegate {
            response: cachedResponse
        }
    }

    InfoBanner {
        id: noLiveInfoBanner
        text: 'No se ha podido consultar la información de tiempos'
    }

    function handleResponse(messageObject) {
        loading = false
        if (messageObject.action === Constants.LOCAL_FETCH_RESPONSE) {
            liveInfo = false
            noLiveInfoBanner.show()
        } else if (messageObject.action === Constants.REMOTE_FETCH_RESPONSE) {
            cachedResponse = messageObject.response
            if (!cachedResponse) {
                asyncWorker.sendMessage({
                                            action: Constants.LOCAL_FETCH_ACTION,
                                            query: 'loadLinesByStop',
                                            model: localModel,
                                            args: { code: stopCode }
                                        })

            } else {
                liveInfo = true
                stopView.lastUpdate = Qt.formatTime(new Date)
            }
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
