// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../components"
import "../../config/jollahelp.js" as DSO

Page {
    ListModel { id: dsoModel
        ListElement {
            title: "Collecting Logs"
            url: "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs"
        }
        ListElement {
            title: "Basic Logs"
            desc:  ""
            url: "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Basic_Logs"
        }
        ListElement {
            title: "Persistent Logs"
            desc:  ""
            url: "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Persistent_Logs/"
        }
        ListElement {
            title: "Email Logs"
            desc:  ""
            url: "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Email_Logs/"
        }
        ListElement {
            title: "oFono Logs"
            desc:  ""
            url: "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_oFono_Logs/"
        }
        ListElement {
            title: "Android Logs"
            desc:  ""
            url: "https://docs.sailfishos.org/Support/Help_Articles/Collecting_Logs/Collect_Logs_with_Logcat/"
        }
    }
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
                model: dsoModel
                delegate: ValueButton { label: qsTr("Article"); value: title; description: url; onClicked: { Qt.openUrlExternally(url)} }
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
