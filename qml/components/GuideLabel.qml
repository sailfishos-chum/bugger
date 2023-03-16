// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0

Column{
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - Theme.horizontalPageMargin
    topPadding: Theme.paddingLarge
    spacing: Theme.paddingMedium
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignJustify
        wrapMode: Text.WordWrap
        text: qsTr('Please review the guidelines and follow the template when creating a bug report.')
    }

    ValueButton {
        label: qsTr("Forum")
        value: qsTr("Guidelines")
        description: "https://forum.sailfishos.org/t/22"
        onClicked: { Qt.openUrlExternally("https://forum.sailfishos.org/t/22")}
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignJustify
        wrapMode: Text.WordWrap
        text: qsTr('If you are uncertain about how to fill out the report, we recommend asking about your issue in the General category of the Forum first:')
    }
}
// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
