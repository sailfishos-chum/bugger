// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0

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
            Label { text: fileName; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeSmall; color: Theme.highlightColor; elide: Text.ElideLeft }
            Label { text: mimeType; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            Row { width: parent.width; spacing: Theme.paddingSmall
            Label { text: (model.fileSize > 0) ? Format.formatFileSize(model.fileSize) : "?"; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            Label { text: (model.pastedUrl) ? qsTr("uploaded"): qsTr("not uploaded"); truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            }
            //Label { text: (model.pastedUrl) ? model.pastedUrl : model.filePath; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
            //Label { text: fileNameOrig ? fileNameOrig : ""; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
        }
    }
    menu: ContextMenu {
        width: (parent) ? parent.width : 0 // gives a log warning but works ;)
        MenuItem { visible: model.pastedUrl; text: qsTr("View online"); onClicked: { Qt.openUrlExternally(model.pastedUrl) } }
        //MenuItem { text: qsTr("View"); onClicked: { pageStack.push("../pages/LogViewPage.qml", { "fileData": model.dataStr, "fileName": model.fileName }) } }
        MenuItem { text: qsTr("View"); onClicked: { console.debug("viewing:", filePath, fileName); pageStack.push("../pages/LogViewPage.qml", { "fileName": model.filePath }) } }
        MenuItem { text: qsTr("Remove from list"); onClicked: remorseDelete(function(){ filesModel.remove(index) }) }
        MenuItem { text: qsTr("Delete file"); onClicked: remorseDelete(function(){ deleteFile(index) }) }
    }
    function deleteFile(index) {
        const fn = filesModel.get(index).filePath
        FileEngine.deleteFiles( [ fn ] )
        FileEngine.fileDeleted.connect(function() {
            console.info("File deleted.")
            filesModel.remove(index)
        });
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
