// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../config/meta.js" as Meta

ValueButton { id: root
    width: parent.width

    property ListModel catModel: ListModel{}
    property int currentIndex: -1
    property string category: (catModel.count > 0 && currentIndex >=0) ? catModel.get(currentIndex).name : "none"

    Component.onCompleted: {
        Meta.data.categories.forEach(function(e){ catModel.append(e) })
    }


    label: qsTr("Bug Category")
    value:       (catModel.count > 0 && currentIndex >=0) ? catModel.get(currentIndex).displayName : qsTr("None")
    description: (catModel.count > 0 && currentIndex >=0) ? catModel.get(currentIndex).description : qsTr("Bug Category")

    onClicked: {
        var dialog = pageStack.push( catDialog, { model: catModel } )
        dialog.accepted.connect(function() { root.currentIndex = dialog.selected })
    }

    Component { id: catDialog // meow!
        Dialog { id: catDlg
            canAccept: (selected != -1) // do it via onClicked on the list delegate
            property int selected: -1
            function select(i) {
                selected = i
                accept()
            }
            property alias model: view.model
            SilicaListView { id: view
                anchors.fill: parent
                header: DialogHeader { id: dlgHead
                    title: qsTr("Bug Category")
                    acceptText: ""
                }
                delegate: ListItem {
                    width: ListView.view.width
                    Column {
                        width: parent.width - Theme.horizontalPageMargin*2
                        anchors.horizontalCenter: parent.horizontalCenter
                        Label { text: displayName; highlighted: true }
                        Label {
                            text: (description.length > 0) ? description : "no description"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.Wrap
                            font.italic: (description.length <= 0)
                        }
                    }
                    onClicked: catDlg.select(index)
                }
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
