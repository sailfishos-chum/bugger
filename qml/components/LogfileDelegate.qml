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

GridItem { id: root
    property string displayName

    anchors.margins: Theme.paddingSmall
    width: GridView.view.cellWidth
    contentHeight: Math.max(GridView.view.cellHeight, Theme.iconSizeLarge, content.height)

    // replicate the 'hidden' property from Sailfish.Silica.ListItem
    property bool hidden
    Item {
        states: State {
            when: root.hidden
            name: "hidden"
            PropertyChanges {
                target: root
                contentHeight: 0
                enabled: false
                opacity: 0.0
            }
        }
    }
    Row { id: content
        height: icon.height
        width: parent.width
        Icon { id: icon
            source: Theme.iconForMimeType(mimeType) //+ '?' + ( (dataStr) ? "green" : Theme.primaryColor )
            height: Theme.iconSizeLarge
            width: height
            sourceSize.width: height
            sourceSize.height: height
        }
        Column {
            width: parent.width - icon.width
            anchors.verticalCenter: icon.verticalCenter
            Label { text: fileName; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeSmall; color: Theme.highlightColor }
            Label { text: mimeType; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            Row { width: parent.width; spacing: Theme.paddingSmall
            Label { text: (model.dataStr) ? Format.formatFileSize(model.dataStr.length) : ""; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            Label { text: (model.pastedUrl) ? qsTr("uploaded"): qsTr("not uploaded"); truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            }
            //Label { text: filePath; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            //Label { text: fileNameOrig ? fileNameOrig : ""; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
        }
    }
    menu: ContextMenu {
        width: (parent) ? parent.width : 0 // gives a log warning but works ;)
        MenuItem { text: qsTr("Remove"); onClicked: remorseDelete(function(){ filesModel.remove(index) }) }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
