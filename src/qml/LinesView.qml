import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha

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
        asyncWorker.sendMessage({
                                    // There are 48 different lines
                                    url: PorCorunha.moveteAPI.get_lines(1, 50)
                                })
    }

    LinesModel {
        id: remoteLinesModel
        xml: cachedResponse
        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                for (var i = 0; i < remoteLinesModel.count; i ++) {
                    if (remoteLinesModel.get(i).direction === 'GO') {
                        linesModel.append({
                                              code: remoteLinesModel.get(i).code,
                                              title: remoteLinesModel.get(i).name,
                                              subtitle: remoteLinesModel.get(i).description
                                          })
                    }
                }
            }
        }
    }

    ListModel {
        id: linesModel
    }

    Header { id: header }

    ListView {
        id: linesList
        clip: true
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: linesModel
        delegate: ListDelegate {
            MoreIndicator {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                appWindow.pageStack.push(lineView,
                                         {
                                             lineCode: model.code,
                                             lineName: model.title,
                                             direction: 'GO',
                                             description: model.subtitle
                                         })
            }
        }
    }

    ScrollDecorator {
        flickableItem: linesList
        anchors.rightMargin: -Constants.DEFAULT_MARGIN
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
