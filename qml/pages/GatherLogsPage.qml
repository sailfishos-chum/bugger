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

    // %h/Documents/$(date -I)_%N.log
    readonly property string logBaseName: svcBaseName + "_svcBaseName.log"
    readonly property string logFileName: new Date().toISOString().substring(0,10) + svcBaseName
    readonly property string logFilePath: StandardPaths.documents + logFileName

    readonly property string svcBaseName: Qt.application.name + "-collect-logs"
    readonly property string svcFileName: svcBaseName + ".service"
    readonly property string svcBusName:  svcFileName.replace(/\./g, "_2e").replace(/-/g, "_2d")

    property bool svcExists:    false
    property bool svcIsEnabled: false

    function queryService()   { dbusManager.queryService() }
    function enableService()  { dbusManager.enableService() }
    function startService()   { dbusUnit.startService() }

    property string logText

    Component.onCompleted: {
        dbusManager.queryService()
    }

    DBusInterface {
        id: dbusManager
        service: 'org.freedesktop.systemd1'
        path: '/org/freedesktop/systemd1'
        iface: 'org.freedesktop.systemd1.Manager'

        function reload() {
            call('Reload')
        }
        function queryService() {
            typedCall('GetUnitFileState',
                { 'type': 's', 'value': svcFileName },
                function(result) {
                    console.debug("Query:", result)
                    page.svcExists = true
                    dbusUnit.queryEnabledState()
                },
                function(error, message) {
                    console.warn('GetUnitFileStatus failed:', error)
                    console.warn('GetUnitFileStatus message:', message)
                    page.svcExists = false 
                })
        }
        function enableService() {
            typedCall('EnableUnitFiles',
                [
                    { 'type': 'as', 'value': [svcFileName] },
                    { 'type': 'b', 'value': false },
                    { 'type': 'b', 'value': false },
                ],
                function(install, changes) {
                    console.debug("Enabled:", install, changes)
                    page.svcIsEnabled = true
                    reload()
                },
                function(error, message) {
                    console.warn("EnableUnitFiles failed:", error)
                    console.warn("EnableUnitFiles message:", message)
                })
        }
    }

    DBusInterface { id: dbusUnit
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        iface: 'org.freedesktop.systemd1.Unit'
        path: '/org/freedesktop/systemd1/unit/' + svcBusName

        function queryEnabledState() {
            var result = getProperty('UnitFileState')
            page.svcIsEnabled = (result == 'enabled')
        }

        function startService() {
            //console.debug("dbus start unit", u );
            call('Start',
                ['replace'],
                function(result) { console.debug("Job:",       JSON.stringify(result)); },
                function(result) { console.warn(qsTr("Start"), JSON.stringify(result)) }
            );
        }
    }

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        Column { id: col
            width: parent.width
            PageHeader { id: header ; title: qsTr("Collect Logs") }
            SectionHeader { text: qsTr("Log Gatherer Status") }
            TextSwitch{ id: unitsw
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                checked: svcIsEnabled
                automaticCheck: false
                enabled: false
                text: qsTr("Gatherer service is %1").arg((page.tmrIsEnabled) ? qsTr("available") : qsTr("not available"))
            }
            SectionHeader { text: qsTr("Journal contents")}
            TextField { id: logText
                width: parent.width
                height: Math.max(implicitHeight, page.height - Theme.itemSizeMedium*5)
                text: (page.logText) ? page.logText : qsTr("No log file yet")
                readOnly: true
                font.family: "monospace"
                color: Theme.secondaryColor
            }
        }
        PullDownMenu { id: pdm
            flickable: flick
            MenuItem { text: qsTr("Gather Logs and Load"); onClicked: { startService() } }
        }
    }

    /* read fileUrl from filesystem, assign to bugInfo according to what */
    function getFile() {

        var r = new XMLHttpRequest()
        r.open('GET', Qt.resolvedUrl(page.logFilePath));
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        r.send();

        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200 || r.status == 0) {
                    page.logText = r.response
                } else {
                    console.warn("XHR failed:", r.response, r.errorText)
                }
            }
        }
    }
}


// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
