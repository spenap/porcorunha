import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants

Item {
    id: listViewArea

    property QtObject elvModel
    property bool loading: false

    signal clicked(variant entry)

    ListView {
        id: listView
        clip: true
        anchors.fill: parent
        model: elvModel
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
