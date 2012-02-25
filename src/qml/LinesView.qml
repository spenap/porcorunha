import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha
import 'storage.js' as Storage
import 'util.js' as Util

Page {
    id: linesView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

    property bool loading: false
    property string cachedResponse: ''

    Component.onCompleted: {
        loading = true
        var lines = Storage.loadLines({ direction: 'GO' })
        if (lines.length === 0) {
            asyncWorker.sendMessage({
                                        action: Constants.ASYNC_FETCH_ACTION,
                                        url: PorCorunha.moveteAPI.get_lines(1, 50)
                                    })
        } else {
            for (var i = 0; i < lines.length; i ++) {
                localModel.append(lines[i])
            }
            loading = false
        }
    }

    LinesModel {
        id: remoteModel
        xml: cachedResponse
        onStatusChanged: {
            if (status === XmlListModel.Ready &&
                    remoteModel.count !== 0) {
                for (var i = 0; i < remoteModel.count; i ++) {
                    var line = new Util.BusLine(remoteModel.get(i).code,
                                                remoteModel.get(i).name,
                                                remoteModel.get(i).direction,
                                                remoteModel.get(i).directionDescription,
                                                remoteModel.get(i).description)
                    if (remoteModel.get(i).direction === 'GO') {
                        localModel.append(line)
                    }
                    if (!inSimulator) {
                        asyncWorker.sendMessage({
                                                    action: Constants.SAVE_LINE_ACTION,
                                                    line: line
                                                })
                    }
                }
                loading = false
            }
        }
    }

    ListModel {
        id: localModel
    }

    Header { id: header }

    ExtendedListView {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: localModel
        loading: linesView.loading
        onClicked: {
            appWindow.pageStack.push(lineView,
                                     {
                                         lineCode: entry.code,
                                         lineName: entry.title,
                                         direction: 'GO',
                                         description: entry.subtitle
                                     })
        }
    }

    function handleResponse(messageObject) {
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
