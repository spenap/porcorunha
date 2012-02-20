import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha

Page {
    id: stopsView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

    Component.onCompleted: {
        loading = true
        asyncWorker.sendMessage({
                                    url: PorCorunha.moveteAPI.get_stops()
                                })
    }

    property string cachedResponse: ''
    property bool loading: false
    property int count: 434
    property int currentPage: 1
    property int length: 10

    StopsModel {
        id: remoteStopsModel
        xml: cachedResponse
        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                for (var i = 0; i < remoteStopsModel.count; i ++) {
                    stopsModel.append({
                                          code: remoteStopsModel.get(i).code,
                                          title: remoteStopsModel.get(i).title,
                                          lat: remoteStopsModel.get(i).lat,
                                          lng: remoteStopsModel.get(i).lng,
                                      })
                }
            }
        }
    }

    ListModel {
        id: stopsModel
    }

    Header { id: header }

    ExtendedListView {
        id: stopsList
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: stopsModel
        loading: stopsView.loading
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
        loading = false
        cachedResponse = messageObject.response
    }

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            handleResponse(messageObject)
        }
    }
}
