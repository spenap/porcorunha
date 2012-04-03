import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants
import 'porcorunha.js' as PorCorunha
import 'storage.js' as Storage

Page {
    id: stopsView

    tools: ToolBarLayout {
        ToolIcon {
            id: backIcon
            iconId: 'toolbar-back'
            onClicked: pageStack.pop()
        }
    }

    orientationLock: PageOrientation.LockPortrait

    property bool emptyFavorites: false

    Component.onCompleted: {
        var codes = controller.favorites()
        if (codes.length > 0) {
            asyncWorker.sendMessage({
                                        action: Constants.LOCAL_FETCH_ACTION,
                                        query: 'loadFavoriteStops',
                                        model: localModel,
                                        args: { codes: codes }
                                    })
        } else {
            emptyFavorites = true
        }
    }

    ListModel {
        id: localModel
    }

    Header { id: header }

    Label {
        platformStyle: LabelStyle {
            fontPixelSize: Constants.FONT_XLARGE
            fontFamily: Constants.FONT_FAMILY_LIGHT
        }
        opacity: 0.5
        horizontalAlignment: Text.AlignHCenter
        text: 'No hay paradas favoritas'
        anchors.centerIn: parent
        visible: emptyFavorites
    }

    ExtendedListView {
        id: stopsList
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Constants.DEFAULT_MARGIN
            rightMargin: Constants.DEFAULT_MARGIN
        }
        model: localModel
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

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            emptyFavorites = (localModel.count === 0)
            console.debug('EmptyFavorites', emptyFavorites)
        }
    }
}
