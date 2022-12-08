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

Page {
    id: page

    property string fileName: ""
    property string fileData: ""

    SilicaListView {
        id: view
        header: PageHeader { title: qsTr("Log File"); description: fileName; width: view.width
            Separator { anchors.verticalCenter: parent.bottom; width: parent.width; color: Theme.primaryColor }
        }
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - Theme.horizontalPageMargin
        topMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingLarge
        model: 1
        delegate: SilicaFlickable {
            width: ListView.view.width
            height: ListView.view.height
            contentHeight: content.height
            contentWidth: content.width
            ScrollDecorator{}
            Label { id: content
                //x: Theme.horizontalPageMargin
                anchors.topMargin: Theme.paddingLarge
                anchors.bottomMargin: Theme.paddingLarge
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium

                text: page.fileData.length > 0 ? page.fileData : ""

                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                font.family: "monospace"
                wrapMode: Text.NoWrap
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
