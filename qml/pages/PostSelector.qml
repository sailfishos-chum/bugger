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
//import "../components"
//import "../config/settings.js" as Settings

Page { id: page
    property string postUrl
    property bool haveSFV: false

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        PageHeader { id: header ;
            width: parent.width
            title: qsTr("Select App to post with")
        }
        Column { id: col
            width: parent.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                horizontalAlignment: Text.AlignJustify
                text: qsTr("There are several way to finally post your report.<br />")
                    + "<ul>"
                    + "<li>" + qsTr("If you choose the Browser, continue on page 38.")
                    + "<li>" + qsTr("If you choose the Forum Viewer, roll a d8 and determine the outcome using the table on page 142.")
                    + "</ul>"
            }
            ButtonLayout {
                width: parent.width
                preferredWidth: Theme.buttonSizeExtraLarge
                Button { label: qsTr("Browser") }
                Button { label: qsTr("Forum Viewer"); enabled: page.haveSFV }
            }
        }
        VerticalScrollDecorator {}
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
