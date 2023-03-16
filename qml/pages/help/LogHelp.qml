// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../components"
import "../../config/help.js" as DSO

Page {
    Component.onCompleted: { DSO.data.forEach(function(e) { helpModel.append(e) }) }
    ListModel { id: helpModel }
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height
        Column { id: content
            width: parent.width
            spacing: Theme.paddingMedium
            PageHeader { title: qsTr("Logging Documentation") }
            SectionHeader { text: qsTr("Native log collecting system") }
            WelcomeLabel {
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("We provide a systemd Target as well as a Service Template to facilitate log gathering.")  + "<br />"
                    + qsTr("App developers have the option ro use a plugin-like system to add their logs to this.")
            }
            SectionHeader { text: qsTr("Sailfish OS Documentation") }
            Repeater {
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                model: helpModel
                delegate: ValueButton { label: category; value: title; description: desc ? desc : url; onClicked: { Qt.openUrlExternally(url)} }
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
