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

Page {
    id: page

    // pointless assignment for debugging with qmlscene, which calls itself "QtQmlViewer":
    readonly property string svcBaseName: "harbour-bugger-gather-logs"
    readonly property string svcFileName: svcBaseName + ".service"
    readonly property string svcBusName:  svcFileName.replace(/\./g, "_2e").replace(/-/g, "_2d")

    property bool svcExists:    false
    property bool svcIsEnabled: false

    function queryService()   { dbusManager.queryService() }
    function startService()   { dbusUnit.startService() }

    property bool logCreated: false

    Component.onCompleted: {
        dbusManager.queryService()
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
            if (unit == page.svcFileName) {
                if (result == "done") {
                    app.popup(qsTr("Log gathering successsful!"))
                    page.logCreated = true;
                } else {
                    app.popup(qsTr("Log gathering failed!"))
                }
            }
        }
        function queryService() {
            typedCall('GetUnitFileState',
                { 'type': 's', 'value': svcFileName },
                function(result) {
                    page.svcExists = true
                },
                function(error, message) {
                    console.warn('GetUnitFileStatus failed:', error)
                    console.warn('GetUnitFileStatus message:', message)
                    page.svcExists = false 
                })
        }
    }

    DBusInterface { id: dbusUnit
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        iface: 'org.freedesktop.systemd1.Unit'
        path: '/org/freedesktop/systemd1/unit/' + svcBusName

        function startService() {
            call('Start',
                ['replace'],
                function(result) { console.debug("Job:",       JSON.stringify(result)); },
                function(result) { console.warn(qsTr("Start"), JSON.stringify(result)) }
            );
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
