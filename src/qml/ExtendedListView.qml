import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants

Item {
    id: listViewArea

    property alias model: listView.model
    property alias delegate: listView.delegate
    property alias header: listView.header
    property bool loading: false

    signal clicked(variant entry)

    ListView {
        id: listView
        clip: true
        anchors.fill: parent
        delegate: ListDelegate {
            MoreIndicator {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                listViewArea.clicked(model)
            }
        }
    }

    ScrollDecorator {
        flickableItem: listView
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
}
