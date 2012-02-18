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
    }

    property int lineCode: 0
    property string lineName: ''
    property string description: ''
    property string direction: 'GO'

    property bool loading: false
    property variant cachedResponse: { 'GO': '', 'RETURN': '' }

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

    ListView {
        id: stopsList
        clip: true
        anchors {
            top: directionFilter.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: XmlListModel {
            xml: cachedResponse[direction]
            query: '/line/stop'

            XmlRole { name: 'code'; query: '@code/string()' }
            XmlRole { name: 'title'; query: '@name/string()' }
            XmlRole { name: 'lat'; query: '@lat/string()' }
            XmlRole { name: 'lng'; query: '@lng/string()' }
            XmlRole { name: 'position'; query: '@position/string()' }
        }

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

    ScrollDecorator {
        flickableItem: stopsList
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
