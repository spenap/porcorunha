import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.location 1.2
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha
import 'storage.js' as Storage
import 'util.js' as Util

Page {
    id: searchView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: {
                if (mapArea.interactive) {
                    mapArea.interactive = false
                } else {
                    pageStack.pop()
                }
            }
        }
    }

    orientationLock: PageOrientation.LockPortrait

    Header { id: header }

    property MapView mapArea

    Component.onCompleted: {
        asyncWorker.sendMessage({
                                    action: Constants.SINGLE_SHOT_ACTION
                                })
    }

    Component.onDestruction: {
        if (mapArea) {
            mapArea.destroy()
        }
    }

    function retrieveStopsNearby() {
        asyncWorker.sendMessage({
                                    action: Constants.LOCAL_FETCH_ACTION,
                                    query: 'searchStopsByCoordinate',
                                    model: localModel,
                                    args: {
                                        latitude: positionSource.position.coordinate.latitude,
                                        longitude: positionSource.position.coordinate.longitude
                                    }
                                })
    }

    TextField {
        id: searchInput
        placeholderText: 'Busca una parada'

        anchors  { top: header.bottom; left: parent.left; right: parent.right }
        anchors.margins: Constants.DEFAULT_MARGIN

        inputMethodHints: Qt.ImhNoPredictiveText
        platformSipAttributes: SipAttributes {
            actionKeyIcon: '/usr/share/themes/blanco/meegotouch/icons/icon-m-toolbar-search-selected.png'
            actionKeyEnabled: searchInput.text
        }

        Keys.onReturnPressed: {
            mapArea.forceActiveFocus()
            asyncWorker.sendMessage({
                                        action: Constants.LOCAL_FETCH_ACTION,
                                        query: 'searchStopsByName',
                                        model: localModel,
                                        args: { name: '%' + searchInput.text + '%' }
                                    })
        }
        Image {
            id: clearText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            source: searchInput.text ?
                        'image://theme/icon-m-input-clear' :
                        ''
        }

        MouseArea {
            id: searchInputMouseArea
            anchors.fill: clearText
            onClicked: {
                searchInput.text = ''
            }
        }
    }

    ListModel {
        id: localModel
    }

    StopsModel {
        id: remoteModel
        source: ''
        onStatusChanged: {
            if (status === XmlListModel.Ready &&
                    remoteModel.count !== 0) {
                for (var i = 0; i < remoteModel.count; i ++) {
                    var stop = new Util.BusStop(remoteModel.get(i).code,
                                                remoteModel.get(i).name,
                                                remoteModel.get(i).lat,
                                                remoteModel.get(i).lng)
                    localModel.append(stop)
                }
                remoteModel.source = ''
                mapArea.fitContentInMap()
            }
        }
    }

    Item {
        id: mapParent
        anchors {
            top: searchInput.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }
        height: Constants.MAP_AREA_HEIGHT
        states: [
            State {
                name: 'fullScreen'
                when: mapArea.interactive
                PropertyChanges {
                    target: mapParent
                    anchors.margins: 0
                    height: parent.height
                }
                AnchorChanges {
                    target: mapParent
                    anchors.top: mapParent.parent.top
                }
            },
            State {
                name: 'widget'
                when: !mapArea.interactive
                PropertyChanges {
                    target: mapParent
                    anchors.margins: Constants.DEFAULT_MARGIN
                    height: Constants.MAP_AREA_HEIGHT
                }
                AnchorChanges {
                    target: mapParent
                    anchors.top: searchInput.bottom
                }
            }
        ]
    }

    Button {
        id: searchButton
        anchors {
            left: parent.left
            right: parent.right
            top: mapParent.bottom
            margins: Constants.DEFAULT_MARGIN
        }
        text: 'Paradas cerca de aquí'
        onClicked: {
            retrieveStopsNearby()
        }
    }

    ExtendedListView {
        id: listView
        anchors {
            top: searchButton.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Constants.DEFAULT_MARGIN
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: localModel
        loading: remoteModel.status === XmlListModel.Loading
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

    function handleResponse(messageObject) {
        if (messageObject.action === Constants.LOCAL_FETCH_RESPONSE) {
            if (localModel.count === 0) {
                remoteModel.source = PorCorunha.moveteAPI.search(searchInput.text)
            } else {
                mapArea.fitContentInMap()
            }
        } else if (messageObject.action === Constants.SINGLE_SHOT_RESPONSE) {
            mapArea = createMapView(mapParent,
                                    {
                                        landmarksModel: localModel
                                    })
            mapArea.clicked.connect(function() {
                                        mapArea.interactive = !mapArea.interactive
                                    })
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
