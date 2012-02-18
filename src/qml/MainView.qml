import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants

Page {
    id: mainView

    Header { id: header }

    ListModel {
        id: mainMenuModel
        ListElement {
            title: 'Líneas'
            method: 0
        }
        ListElement {
            title: 'Paradas'
            method: 1
        }
        ListElement {
            title: 'Búsqueda'
            method: 2
        }
    }

    Column {
        id: column
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }

        Repeater {
            model: mainMenuModel
            delegate: ListDelegate {
                MoreIndicator {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked: handleSelectedMethod(model.method)
            }
        }
    }

    function handleSelectedMethod(method) {
        switch (method) {
        case 0:
            appWindow.pageStack.push(linesView)
            break
        case 1:
            appWindow.pageStack.push(stopsView)
            break
        case 2:
            appWindow.pageStack.push(searchView)
            break
        }
    }

    Component {
        id: linesView
        LinesView { }
    }

    Component {
        id: stopsView
        StopsView { }
    }

    Component {
        id: lineView
        LineView { }
    }

    Component {
        id: stopView
        StopView { }
    }

    Component {
        id: searchView
        SearchView { }
    }
}
