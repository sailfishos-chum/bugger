/*

Apache License 2.0

Copyright (c) 2022 Peter G. (nephros)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  
You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../config/sfos_versions.js" as SFOS

Column {
    width: parent.width
    property var sfosData: SFOS.data

    property alias currentIndex: cbox.currentIndex
    property alias value: cbox.value

    states: [
        State { name: "version"
            PropertyChanges{ target: cbox; menu: vermenu ; label: qsTr("Version"); description: qsTr("Working Version")}
        },
        State { name: "arch"
            PropertyChanges{ target: cbox; menu: archmenu ; label: qsTr("Arch"); description: qsTr("Working Version")}
        }
    ]
    ContextMenu { id: archmenu
        Repeater {
            model: sfosData.arch
            delegate: MenuItem { text: modelData }
        }
    }
    ContextMenu { id: vermenu
        Repeater {
            model: sfosData.version
            delegate: MenuItem { text: modelData }
        }
    }
    ComboBox {id: cbox
        width: parent.width
        currentIndex: -1
    }
}
// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
