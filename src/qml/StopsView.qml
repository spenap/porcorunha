import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants

Page {
    id: stopsView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

    property int count: 434
    property int currentPage: 1
    property int length: 10

    function getUrl(page, length) {
        return 'http://movete.trabesoluciones.net/coruna/bus/stops/list?page=' +
                page +
                '&length=' +
                length
    }

    Header { id: header }

    ListView {
        id: stopsList
        clip: true
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: StopsModel {
            source: stopsView.status === PageStatus.Active ?
                        getUrl(currentPage, length) :
                        ''
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
        visible: stopsList.model.status === XmlListModel.Loading
        platformStyle: BusyIndicatorStyle {
            size: 'large'
        }
    }
}
