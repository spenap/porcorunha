import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as Constants

Item {
    width: parent.width
    height: appWindow.inPortrait ?
                Constants.HEADER_DEFAULT_HEIGHT_PORTRAIT :
                Constants.HEADER_DEFAULT_HEIGHT_LANDSCAPE

    BorderImage {
        id: background
        anchors.fill: parent
        source: 'image://theme/color4-meegotouch-view-header-fixed'
    }

    Text {
        id: headerText
        anchors.top: parent.top
        anchors.topMargin: appWindow.inPortrait ?
                               Constants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT :
                               Constants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
        anchors.left: parent.left
        anchors.leftMargin: Constants.DEFAULT_MARGIN
        font.pixelSize: Constants.FONT_LARGE
        font.family: Constants.FONT_FAMILY
        text: 'Por Coruña'
        color: Constants.HEADER_FOREGROUND_COLOR
    }
}
