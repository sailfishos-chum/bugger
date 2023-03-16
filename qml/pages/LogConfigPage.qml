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
//import "../components"
//import "../config/settings.js" as Settings
import "../config/logconfig.js" as Logs

Page { id: page

    property var config: Settings.config

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        PageHeader { id: header ; width: parent.width ; title: qsTr("Prepare Logging") }
        SilicaListView { id: col
            width: parent.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            model: Logs
            delegate: ListItem {
                    Label { text: displayName}
                    Label { text: path}
            }
        //PullDownMenu { id: pdm
        //    flickable: flick
        //    MenuItem { text: qsTr("Upload Contents"); onClicked: { upload() } }
        //    MenuItem { text: qsTr("Pick Files"); onClicked: pageStack.push(picker) }
        //    MenuItem { text: qsTr("Collect Logs"); onClicked: { startGatherer() } }
        //}
        }
    }
    VerticalScrollDecorator {}
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
