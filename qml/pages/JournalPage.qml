/*

Apache License 2.0

Copyright (c) 2023 Peter G. (nephros)

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
import Nemo.FileManager 1.0
import "../components"
import "../config/settings.js" as Settings

Page { id: page

    property var config: Settings.config

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
        PageHeader { id: header ; width: parent.width ; title: qsTr("Journal Config") }
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
            TextSwitch {
                checked: jrnlConf.exists
                //automaticCheck: false
                busy: jrnlRefresh.running
                text: qsTr("Full debugging")
                description: qsTr("If enabled, the Journal daemon will persist logs, and log at Debug levels. Do remember to turn this off again.\nAuthentication may be required on toggle.")
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
                   // onTriggered: jrnlConf.refresh()
                }
            }
        }
        VerticalScrollDecorator {}
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
