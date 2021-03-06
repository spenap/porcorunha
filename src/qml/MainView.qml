import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants
import 'storage.js' as Storage

Page {
    id: mainView

    orientationLock: PageOrientation.LockPortrait

    Component.onCompleted: {
        Storage.initialize()
    }

    Menu {
        id: mainMenu
        MenuLayout {
            MenuItem {
                id: aboutEntry
                text: 'Acerca de'
                onClicked: appWindow.pageStack.push(aboutView)
            }
        }
    }

    tools: ToolBarLayout {
        id: commonTools

        ToolIcon {
            iconId: 'toolbar-view-menu'
            anchors.right: parent.right
            onClicked: (mainMenu.status === DialogStatus.Closed) ?
                           mainMenu.open() : mainMenu.close()
        }
    }

    Header { id: header }

    ListModel {
        id: mainMenuModel
        ListElement {
            title: 'Información de líneas'
            method: 0
            iconSource: 'qrc:/resources/icon-xxl-bus-stop.png'
        }
        ListElement {
            title: 'Paradas favoritas'
            method: 1
            iconSource: 'qrc:/resources/icon-xxl-bus-stop.png'
        }
        ListElement {
            title: 'Búsqueda'
            method: 2
            iconSource: 'qrc:/resources/icon-xxl-search.png'
        }
    }

    Column {
        id: column
        spacing: 2 * Constants.DEFAULT_MARGIN
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Constants.DEFAULT_MARGIN
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }

        Repeater {
            model: mainMenuModel
            delegate: Component {
                id: mainMenuDelegate
                Rectangle {
                    width: parent.width
                    height: 190
                    radius: 20
                    color: 'darkgrey'
                    opacity: mouseArea.pressed ? 0.5 : 1

                    Image {
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            margins: Constants.DEFAULT_MARGIN
                        }
                        source: model.iconSource
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: model.title
                        platformStyle: LabelStyle {
                            fontPixelSize: Constants.FONT_XXXLARGE
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: handleSelectedMethod(model.method)
                    }
                }
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
        id: lineView
        LineView { }
    }

    Component {
        id: stopView
        StopView { }
    }

    Component {
        id: stopsView
        StopsView { }
    }

    Component {
        id: searchView
        SearchView { }
    }

    Component {
        id: aboutView
        AboutView { }
    }
}
