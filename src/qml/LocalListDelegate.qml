/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

// Inspiration for the accordion behaviour comes from
// https://projects.forum.nokia.com/QMLTemplates/browser/AccordionList/component/AccordionList.qml

import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as UI
import 'util.js' as Util

Item {
    id: listItem

    signal clicked

    property string code: model.code
    property string titleText: model.title
    property string subtitleText: model.subtitle ? model.subtitle : ''
    property string response: ''
    property bool expanded: false

    height: UI.LIST_ITEM_HEIGHT + subItems.height
    width: parent.width

    XmlListModel {
        id: remoteModel
        xml: response
        query: '/stop/line[@code=' + listItem.code + ']/vehicle'

        XmlRole { name: 'code'; query: '@code/string()' }
        XmlRole { name: 'time'; query: '@time/number()' }
        XmlRole { name: 'distance'; query: '@distance/string()' }

        onStatusChanged: {
            if (status === XmlListModel.Ready &&
                    remoteModel.count !== 0) {
                for (var i = 0; i < remoteModel.count; i ++) {
                    var busTime = new Util.BusTime(remoteModel.get(i).code,
                                                   remoteModel.get(i).time,
                                                   remoteModel.get(i).distance)
                    localModel.append(busTime)
                }

            }
        }
    }

    ListModel {
        id: localModel
    }

    Column {
        id: delegateColumn
        anchors.fill: parent

        Item {
            height: UI.LIST_ITEM_HEIGHT
            width: parent.width
            clip: true

            BorderImage {
                id: background
                anchors {
                    fill: parent
                    leftMargin: -UI.MARGIN_XLARGE
                    rightMargin: -UI.MARGIN_XLARGE
                }
                visible: mouseArea.pressed
                source: 'image://theme/meegotouch-panel-background-pressed'
            }

            Column {
                anchors.topMargin: 2
                anchors.fill: parent

                Label {
                    id: mainText
                    text: listItem.titleText
                    platformStyle: LabelStyle {
                        fontPixelSize: UI.LIST_TILE_SIZE
                    }
                    font.weight: Font.Bold
                    color: mouseArea.pressed ? UI.LIST_TITLE_COLOR_PRESSED : UI.LIST_TITLE_COLOR
                }

                Label {
                    id: subText
                    text: listItem.subtitleText ? listItem.subtitleText : ''
                    platformStyle: LabelStyle {
                        fontPixelSize: UI.LIST_SUBTILE_SIZE
                        fontFamily: UI.FONT_FAMILY_LIGHT
                    }
                    color: mouseArea.pressed ? UI.LIST_SUBTITLE_COLOR_PRESSED : UI.LIST_SUBTITLE_COLOR

                    visible: text !== ''
                }
            }

            MouseArea {
                id: mouseArea;
                anchors.fill: parent
                onClicked: {
                    listItem.expanded = !listItem.expanded
                }
            }

            MoreIndicator {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                rotation: listItem.expanded ? -90 : 90
                visible: response

                Behavior on rotation {
                    NumberAnimation { duration: 100 }
                }
            }
        }

        Item {
            id: subItems
            width: parent.width
            height: expanded ? remoteModel.count * UI.LIST_ITEM_HEIGHT : 0
            clip: true

            Behavior on height {
                NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
            }

            Column {
                width: parent.width

                Repeater {
                    id: accordionRepeater
                    width: parent.width
                    model: localModel
                    delegate: ListDelegate {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: UI.DEFAULT_MARGIN
                    }
                }
            }
        }
    }
}
