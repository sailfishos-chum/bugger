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

Dialog {
    canAccept: false
    forwardNavigation: false
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height
        Column { id: content
            width: parent.width
            DialogHeader {
                title: qsTr("Welcome")
                cancelText: qsTr("Dismiss")
                acceptText: ""
            }
            WelcomeLabel{ width:  parent.width - Theme.horizontalPageMargin
                text: qsTr('Welcome to the inofficial Sailfish OS bug reporting tool.') }
            WelcomeLabel{ width:  parent.width - Theme.horizontalPageMargin }
            L10NNotice{ width:  parent.width - Theme.horizontalPageMargin }
            GuideLabel{ width:  parent.width - Theme.horizontalPageMargin }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
