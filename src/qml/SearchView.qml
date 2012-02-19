import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtMobility.location 1.2
import 'constants.js' as Constants

Page {
    id: searchView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

    function getUrl(searchTerm) {
        return 'http://movete.trabesoluciones.net/coruna/bus/stops/search?terms=' +
                searchTerm +
                '&page=1&length=20'
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
            resultsList.model.source = getUrl(searchInput.text)
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

    Item {
        id: mapArea
        anchors {
            top: searchInput.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }
        height: Constants.MAP_AREA_HEIGHT

        Map {
            id: map
            plugin : Plugin {
                name : 'nokia'
            }
            size.width: parent.width
            size.height: parent.height
            zoomLevel: 14
            center: positionSource.position.coordinate

            MapCircle {
                center: positionSource.position.coordinate
                radius: 50
                color: '#80ff0000'
                border {
                    width: 1
                    color: 'red'
                }
            }

            MapCircle {
                center: positionSource.position.coordinate
                radius: 80
                color: 'transparent'
                border {
                    width: 2
                    color: 'red'
                }
            }
        }

        Rectangle {
            width: stopLabel.implicitWidth + Constants.DEFAULT_MARGIN
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            color: '#80808080'
            radius: 10
            border {
                color: 'darkgrey'
                width: 2
            }

            Label {
                id: stopLabel
                anchors.centerIn: parent
                text: appWindow.address
                color: 'white'
            }
        }
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
        model: StopsModel {
            source: ''
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
