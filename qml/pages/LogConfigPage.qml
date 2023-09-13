// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import Nemo.FileManager 1.0
import "../components"
import "../config/settings.js" as Settings

Page { id: page

    property var config: Settings.config
    property bool collectEnabled
    property bool pluginEnabled
    property var watchedJobs: new Object()      // record jobs we launched, used as key-value store

    function successMsg(message, result) {
        app.popup(result + ": " + message)
        console.debug(result + ": " + message)
    }
    function failMsg(message, result) {
        app.popup(result + ": " + message)
        console.warn(result + ": " + message)
    }
    DBusInterface { id: manager
        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"
        propertiesEnabled: true

        function toggleGather() {
            var u = "harbour-bugger-gather-logs.target"
            getUnitState(u, function(state){
                if (state === "enabled") disable(u)
                if (state === "disabled") enable(u)
            })
        }
        function togglePlugins() {
            var u = "harbour-bugger-gather-logs-plugin@.service"
            getUnitState(u, function(state){
                if (state === "enabled") disable(u)
                if (state === "disabled") enable(u)
            })
        }
        function enable(u) {
            //console.debug("dbus enable unit", u );
            typedCall('EnableUnitFiles', [
                { "type": "as", "value": [u] },
                { "type": "b", "value": false },
                { "type": "b", "value": false },
            ],
                function(result) { successMsg(qsTr("Enable %1").arg(u), result[1]); app.refresh() },
                function(result) { failMsg(qsTr("Enable %1").arg(u), result[1]) }
            );
        }
        function disable(u) {
            //console.debug("dbus disable unit", u );
            typedCall('DisableUnitFiles', [
                { "type": "as", "value": [u] },
                { "type": "b", "value": false },
            ],
                function(result) { successMsg(qsTr("Disable %1").arg(u), result); app.refresh() },
                function(result) { failMsg(qsTr("Disable %1").arg(u), result) }
            );
        }
        function start(u) {
            //console.debug("dbus start unit", u );
            call('StartUnit',
                [u, "replace",],
                function(result) { console.debug("Job:", JSON.stringify(result)); watchJob(result, qsTr("Start")); },
                function(result) { failMsg(qsTr("Start %1").arg(u), result) }
            );
        }
        function stop(u) {
            //console.debug("dbus stop unit", u );
            call('StopUnit',
                [u, "replace",],
                function(result) { console.debug("Job:", JSON.stringify(result)); watchJob(result, qsTr("Stop")); },
                function(result) { failMsg(qsTr("Stop %1").arg(u), result) }
            );
        }
        function restart(u) {
            //console.debug("dbus restart unit", u );
            call('RestartUnit',
                [u, "replace",],
                function(result) { console.debug("Job:", JSON.stringify(result)); watchJob(result, qsTr("Restart")); },
                function(result) { failMsg(qsTr("Restart %1").arg(u), result) }
            );
        }
        function preset(u) {
            //console.debug("dbus restart unit", u );
            call('PresetUnitFiles',
                [u, false, false,],
                function(result) { successMsg(qsTr("Preset %1").arg(u), result) },
                function(result) { failMsg(qsTr("Preset %1").arg(u), result) }
            );
        }
        function daemon_reload() {
            //console.debug("daemon reload ");
            call('Reload',
                [],
                function(result) { successMsg(qsTr("Preset %1").arg(u), result) },
                function(result) { failMsg(qsTr("Preset %1").arg(u), result) }
            );
        }

        //signal handler for finished jobs:
        function jobRemoved(id, job, unit, result) {
            // TODO: maybe we want notifications about all jobs:
            if (!watchedJobs.hasOwnProperty(job) ) { return; }
            console.debug("Job removed: ", id, "/", result, unit)
            if (result == "done") {
                successMsg(watchedJobs[job], qsTr("%2 for unit %3", "successful message, e.g. 'start for unit foo'").arg(result).arg(unit))
            } else {
                failMsg(watchedJobs[job], qsTr("%1 %2 for unit %3","failure message, e.g. 'starting failed for unit foo'").arg(watchedJobs[job]).arg(result).arg(unit))
            }
            unwatchJob(job);
            app.refresh();
        }
        // handle the internal job queue, we only report jobs we triggered:
        // TODO: maybe we want notifications about all jobs:
        function watchJob(job, action) {
            console.debug("watching:",job);
            watchedJobs[job] = action;
        }
        function unwatchJob(job) {
            console.debug("unwatching:",job);
            if (watchedJobs.hasOwnProperty(job)) {
                delete watchedJobs[job];
            } else {
                console.warn("Trying to remove job not in list");
            }
        }

        // parameters: unit, callback cb
        function getUnitState(u, cb) {
            call('GetUnitFileState',
                [u],
                function(result) { cb(result) },
                function(result) { console.debug("failure: ", u, result) }
            );
        }
    }

    DBusInterface { id: journald
        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/harbour_2dbugger_2djournalconf_2eservice"
        iface: "org.freedesktop.systemd1.Unit"

        propertiesEnabled: true
        property string activeState
        function toggle() {
            if (activeState == "inactive") {
                call('Start',
                    ["replace",],
                    function(result) { console.debug("Job:", JSON.stringify(result)); },
                    function(error, message) { console.warn("Error starting:", message
                    ) }
                );
            } else {
                console.warn("Trying to toggle while %1, ignoring".arg(activeState))
            }
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
                    journald.toggle();
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
                    manager.toggleGather()
                }
            }
            TextSwitch { id: pluginsw
                checked: pluginEnabled
                text: qsTr("Plugin System")
                description: qsTr("If enabled, apps which use the Plugin system will have their logs added to thelog cache.") + '\n' + qsTr("Authentication may be required on toggle.")
                onClicked:  {
                    manager.togglePlugins()
                }
            }
        }
        VerticalScrollDecorator {}
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
