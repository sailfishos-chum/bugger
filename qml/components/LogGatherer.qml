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
import Nemo.DBus 2.0

Item { id: root

    readonly property string unitBaseName: "harbour-bugger-gather-logs"
    readonly property string svcFileName: unitBaseName + ".service"
    readonly property string tgtFileName: unitBaseName + ".target"
    readonly property string tgtBusName:  svcFileName.replace(/\./g, "_2e").replace(/-/g, "_2d")

    property bool svcExists:    false
    property bool tgtExists:    false
    property bool tgtIsEnabled: false

    function start() { dbusTarget.startTarget() }

    property bool logCreated: false

    Component.onCompleted: {
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
                    root.logCreated = true;
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
