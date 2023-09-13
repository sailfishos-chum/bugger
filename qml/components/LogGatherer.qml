// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.DBus 2.0

Item { id: root

    readonly property string unitBaseName: "harbour-bugger-gather-logs"
    readonly property string svcFileName: unitBaseName + ".service"
    readonly property string tgtFileName: unitBaseName + ".target"
    readonly property string tgtBusName:  tgtFileName.replace(/\./g, "_2e").replace(/-/g, "_2d")

    property bool svcExists:    false
    property bool tgtExists:    false
    property bool tgtIsEnabled: false

    property string knownUnits

    function start() { dbusTarget.startTarget() }
    function listUnits() {
        dbusManager.call("ListUnits", [],
            function(result) {
                var running = []
                result.forEach(function(e) {
                    //"unit", "desc", "loaded", "status", "sub", "followed",
                    //"service", "numjobs", "jobs", "jobpath",
                    //"custom",
                    if (! /service$/.test(e[0])) return
                    if (e[2] == "loaded" && (e[3] == "active" || e[3] == "failed")) {
                        running.push(e[0])
                    }
                })
                knownUnits = running.join(',')
                console.debug(knownUnits)
            },
            function(result) { console.warn(qsTr("Start"), JSON.stringify(result)) }
        );
    }
    function collectLog(unit) {
        dbusManager.call("StartUnit",
            [ unit,"replace"],
            function(result) { },
            function(result) { console.warn(qsTr("Start"), JSON.stringify(result)) }
        );
    }

    Component.onCompleted: {
    listUnits()
        dbusManager.queryService()
        dbusManager.queryTarget()
    }

    DBusInterface {
        id: dbusManager
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1'
        iface: 'org.freedesktop.systemd1.Manager'

        // receive signals:
        signalsEnabled: true;
        Component.onCompleted: call('Subscribe')

        function reload() {
            call('Reload')
        }

        // signal handler for finished job:
        function jobRemoved(id, job, unit, result) {
            // NB: we listen for the service to be done, not the target.
            // we don't want to go into an endless loop of popups.
            if (unit == root.svcFileName) {
                if (result == "done") {
                    app.popup(qsTr("Log gathering successsful!"))
                } else {
                    app.popup(qsTr("Log gathering failed!"))
                }
            }
        }
        function queryService() {
            typedCall('GetUnitFileState',
                { 'type': 's', 'value': svcFileName },
                function(result) {
                    root.svcExists = true
                },
                function(error, message) {
                    console.warn('GetUnitFileStatus failed:', error)
                    console.warn('GetUnitFileStatus message:', message)
                    root.svcExists = false 
                })
        }
        function queryTarget() {
            typedCall('GetUnitFileState',
                { 'type': 's', 'value': tgtFileName },
                function(result) {
                    root.tgtExists = true
                },
                function(error, message) {
                    console.warn('GetUnitFileStatus failed:', error)
                    console.warn('GetUnitFileStatus message:', message)
                    root.tgtExists = false
                })
        }
    }

    DBusInterface { id: dbusTarget
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        iface: 'org.freedesktop.systemd1.Unit'
        path: '/org/freedesktop/systemd1/unit/' + tgtBusName

        function startTarget() {
            call('Restart',
                ['replace'],
                function(result) { }, //console.debug("Job:",       JSON.stringify(result)); },
                function(result) { console.warn(qsTr("Start"), JSON.stringify(result)) }
            );
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
