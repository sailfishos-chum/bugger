// Copyright (c) 2022, 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    property string fileName: ""
    property string fileData: ""

    PageHeader { id: header
        title: qsTr("Log File"); description: fileName
        Separator { anchors.verticalCenter: parent.bottom; width: parent.width; color: Theme.primaryColor }
    }

    SilicaFlickable { id: flick
        clip: true
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.height - header.height
        contentHeight: content.height
        contentWidth: content.width
        //topMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingLarge
        leftMargin: Theme.horizontalPageMargin
        rightMargin: Theme.horizontalPageMargin
        //rightMargin: Theme.paddingMedium
        ScrollDecorator{}
        Label { id: content
            //x: Theme.horizontalPageMargin

            text: page.fileData.length > 0 ? page.fileData : ""

            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            font.family: "monospace"
            wrapMode: Text.NoWrap
            verticalAlignment: Text.AlignVCenter
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
