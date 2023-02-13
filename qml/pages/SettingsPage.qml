/*

 Copyright (c) 2023 Peter G. (nephros)

*/
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: settingsPage

    SilicaFlickable{
        anchors.fill: parent
        contentHeight: col.height
        Column {
            id: col
            spacing: Theme.paddingSmall
            bottomPadding: Theme.itemSizeLarge
            width: parent.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            PageHeader{ title: qsTr("Settings", "page title")}
            SectionHeader {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Application")
            }

            TextSwitch{
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                checked: app.sfvIntegration
                automaticCheck: true
                text: qsTr("Use Forum Viewer for posting")
                description: qsTr("If enabled, the app will use the SailfishOS Forum Viewer app instead of the Browser for report submission.")
                onClicked: app.sfvIntegration = checked
            }
        }
        VerticalScrollDecorator {}
    }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
