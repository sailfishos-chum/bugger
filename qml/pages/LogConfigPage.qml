// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import "../components"
import "../components/singletons"
import "../config/settings.js" as Settings

Page { id: page

    property var config: Settings.config
    property bool collectEnabled
    property bool pluginEnabled

    property var watchedJobs: new Object()      // record jobs we launched, used as key-value store

    // fixme: we can't actually determine active state for a target and a template...
    onStatusChanged: {
        if (status == PageStatus.Active) {
            const u
            u = "harbour-bugger-gather-logs.target"
            DBusManager.getUnitState(u, function(state){
                collectEnabled = (state === "enabled")
            })
            u = "harbour-bugger-gather-logs-plugin@harbour-bugger-gather-logs.service"
            DBusManager.getUnitState(u, function(state){
                pluginEnabled = (state === "enabled")
            })
        }
    }

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        PageHeader { id: header ; width: parent.width ; title: qsTr("Logging Configuration") }
        Column { id: col
            width: parent.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                text: qsTr("Here you can configure various settings regarding logging.")
            }
            SectionHeader { text: qsTr("Journal") }
            TextSwitch {
                checked: jrnlConf.exists
                //automaticCheck: false
                busy: jrnlRefresh.running
                text: qsTr("Full debugging")
                description: qsTr("If enabled, the Journal daemon will persist logs, and log at Debug levels. Do remember to turn this off again.") + '\n' + qsTr("Authentication may be required on toggle.")
                onClicked:  {
                    if (busy) return;
                    DBusManager.toggleJournal();
                    jrnlRefresh.restart()
                }
                FileWatcher { id: jrnlConf
                    fileName:'/etc/systemd/journal.conf.d/99_bugger_full_debug.conf'
                    onExistsChanged: console.debug("Journal Debug config %1".arg(exists ? "exists" : "does not exist" ))
                }
                Timer { id: jrnlRefresh
                    interval: 1500
                    running: true
                }
            }
            SectionHeader { text: qsTr("Log Collectors") }
            TextSwitch { id: collectsw
                checked: collectEnabled
                text: qsTr("Default Collectors")
                description: qsTr("If enabled, the default logs are collected.") + '\n' + qsTr("Authentication may be required on toggle.")
                onClicked:  {
                    DBusManager.toggleGather()
                }
            }
            TextSwitch { id: pluginsw
                checked: pluginEnabled
                text: qsTr("Plugin System")
                description: qsTr("If enabled, apps which use the Plugin system will have their logs added to thelog cache.") + '\n' + qsTr("Authentication may be required on toggle.")
                onClicked:  {
                    DBusManager.togglePlugins()
                }
            }
        }
        VerticalScrollDecorator {}
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
