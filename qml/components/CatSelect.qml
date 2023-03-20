// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../config/meta.js" as Meta

Column {
    width: parent.width
    property var catData: Meta.data.categories

    property alias currentIndex: cbox.currentIndex
    property alias value: cbox.value
    ContextMenu { id: catmenu
        Repeater {
            model: catData
            delegate: MenuItem { text: modelData.displayName }
        }
    }
   ComboBox {id: cbox
        width: parent.width
       label: qsTr("Category")
       description: qsTr("Type of bug/classification")
        currentIndex: -1
        menu: catmenu
    }
}
// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
