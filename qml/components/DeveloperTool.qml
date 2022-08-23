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

Column { id: devCol
    readonly property string lorem: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
    ButtonLayout {
        width: parent.width
        Button {
            text: "Fill minumum"
            onClicked: {
                text_title.text = "[Test] LoremIpsum Report"
                text_desc.text = devCol.lorem
                text_steps.text = devCol.lorem
            }
        }
        Button {
            text: "Fill the rest"
            onClicked: {
                text_precons.text = devCol.lorem
                text_expres.text = devCol.lorem
                text_actres.text = devCol.lorem
            }
        }
    }
    Label {
        width:  parent.width - Theme.horizontalPageMargin * 2
        color: Theme.secondaryColor
        font.italic: true
        font.pixelSize: Theme.fontSizeSmall
        text: "gootcnt: " + infoGoodCnt + " fullcnt: " + infoFullCnt + " state: " + page.state
    }
}


// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
