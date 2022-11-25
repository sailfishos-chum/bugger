/*

Apache License 2.0

Copyright (c) 2022 Peter G. (nephros)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

import QtQuick 2.6
import Sailfish.Silica 1.0

GridItem {
    property bool selected: false
    property string mimeType: ""
    property string displayName

    anchors.margins: Theme.paddingSmall
    width: GridView.view.cellWidth
    contentHeight: Math.max(GridView.view.cellHeight, Theme.iconSizeMedium, content.height)
    Row { id: content
        height: icon.height
        width: parent.width
        Switch { width: Theme.iconSizeSmall; height: width; anchors.verticalCenter: icon.verticalCenter
            checked: selected;
        }
        Icon { id: icon
            source: Theme.iconForMimeType(mimeType)
            height: Theme.iconSizeMedium
            width: height
            sourceSize.width: height
            sourceSize.height: height
        }
        Column {
            width: parent.width - icon.width
            anchors.verticalCenter: icon.verticalCenter
            Label { text: fileName; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeSmall; color: Theme.highlightColor }
            Label { text: mimeType; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            //Label { text: filePath; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            //Label { text: fileNameOrig ? fileNameOrig : ""; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
        }
    }
    onClicked: selected = !selected
    highlighted: selected
    menu: ContextMenu {
        width: (parent) ? parent.width : 0 // gives a log warning but works ;)
        MenuItem { text: qsTr("Remove"); onClicked: { content.hidden = true; selectedFiles.remove(index,1) } }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
