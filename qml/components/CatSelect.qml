// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../config/meta.js" as Meta

ComboBox {
    width: parent.width

    Component.onCompleted: {
        Meta.data.categories.forEach(function(e){ catModel.append(e) })
        cmenu.entries = catModel
        menu = cmenu
    }

    property ListModel catModel: ListModel{}
    property string category: (catModel.count > 0 && currentIndex >=0) ? catModel.get(currentIndex).name : "none"

    label: qsTr("Category")
    value:       (catModel.count > 0 && currentIndex >=0) ? catModel.get(currentIndex).displayName : qsTr("None")
    description: (catModel.count > 0 && currentIndex >=0) ? catModel.get(currentIndex).description : qsTr("Bug Category")
    ContextMenu { id: cmenu
        property alias entries: entriesrep.model
        Repeater { id: entriesrep
            delegate: MenuItem { text: Theme.highlightText(displayName + ((description.length >0) ? ": " + description : ""), displayName, Theme.highlightColor) }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
