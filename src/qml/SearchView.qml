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
            stopsModel.source = PorCorunha.moveteAPI.search(searchInput.text)
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
                stopsModel.source = ''
            }
        }
    }

    StopsModel {
        id: stopsModel
        source: ''
    }

    MapView {
        id: mapArea
        anchors {
            top: searchInput.bottom
            left: parent.left
            right: parent.right
            margins: Constants.DEFAULT_MARGIN
        }
        landmarksModel: stopsModel
    }

    ExtendedListView {
        id: listView
        anchors {
            top: mapArea.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: stopsModel
        loading: stopsModel.status === XmlListModel.Loading
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
}
