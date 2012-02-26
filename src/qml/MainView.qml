import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants
import 'storage.js' as Storage

Page {
    id: mainView

    Component.onCompleted: {
        Storage.initialize()
    }

    Header { id: header }

    ListModel {
        id: mainMenuModel
        ListElement {
            title: 'Información de líneas'
            method: 0
            iconSource: 'qrc:/resources/icon-xxl-bus-stop.png'
        }
//        ListElement {
//            title: 'Paradas'
//            method: 1
//        }
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
                    height: 220
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
                            margins: Constants.DEFAULT_MARGIN
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

    Column {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Constants.DEFAULT_MARGIN
        }

        Label {
            width: parent.width
            text: 'Por Coruña - 1.0.0'
            horizontalAlignment: Text.AlignHCenter
            platformStyle: LabelStyle {
                fontPixelSize: Constants.FONT_LARGE
            }
        }
        Label {
            width: parent.width
            text: 'Copyright © 2012 Simon Pena'
            horizontalAlignment: Text.AlignHCenter
            platformStyle: LabelStyle {
                fontPixelSize: Constants.FONT_LARGE
            }
        }
        Label {
            width: parent.width
            text: '<a href="mailto:spena@igalia.com">spena@igalia.com</a> | ' +
                  '<a href="http://www.simonpena.com/?utm_source=harmattan&utm_medium=apps&utm_campaign=porcorunha">simonpena.com</a>'
                    horizontalAlignment: Text.AlignHCenter
            onLinkActivated: Qt.openUrlExternally(link)
            platformStyle: LabelStyle {
                fontPixelSize: Constants.FONT_SMALL
            }
        }
        Label {
            width: parent.width
            text: 'Esta aplicación usa la API de transporte público ' +
                  '<a href="http://movete.trabesoluciones.net/?utm_source=harmattan&utm_medium=apps&utm_campaign=porcorunha">movete.trabesoluciones.net</a>. '+
                  'Los datos mostrados se proporcionan con la intención de que sean útiles, pero '+
                  'no se puede garantizar su validez.'
            onLinkActivated: Qt.openUrlExternally(link)
            platformStyle: LabelStyle {
                fontPixelSize: Constants.FONT_SMALL
            }
            horizontalAlignment: Text.AlignJustify
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    function handleSelectedMethod(method) {
        switch (method) {
        case 0:
            appWindow.pageStack.push(linesView)
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
        id: searchView
        SearchView { }
    }
}
