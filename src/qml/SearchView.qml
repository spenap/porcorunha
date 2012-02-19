import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.location 1.2
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha

Page {
    id: searchView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

    Header { id: header }

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
            resultsList.model.source = PorCorunha.moveteAPI.search(searchInput.text)
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
                resultsList.model.source = ''
            }
        }
    }

    StopsModel {
        id: stopsModel
        source: ''

        onStatusChanged: {
            console.debug('Status:', status)
        }
    }

    MapView {
        id: mapArea
        anchors {
            top: searchInput.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }
        height: Constants.MAP_AREA_HEIGHT
        landmarksModel: stopsModel
    }

    ListView {
        id: resultsList
        clip: true
        anchors {
            top: mapArea.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
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

    ScrollDecorator {
        flickableItem: resultsList
        anchors.rightMargin: -Constants.DEFAULT_MARGIN
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: visible
        visible: resultsList.model.status === XmlListModel.Loading
        platformStyle: BusyIndicatorStyle {
            size: 'large'
        }
    }
}
