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
import "../js/util.js" as Util

Column { id: devCol
    readonly property string lorem: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
    ButtonLayout {
        width: parent.width
        Button {
            text: "Fill minumum"
            onClicked: {
                text_title.text = "Rosencrantz and Guildenstern are dead" 
                text_desc.text =  "Something is rotten in the state of Denmark."
                text_steps.text = "1. To be,\n 2. or not to be,\n 3. that is the question"
            }
        }
        Button {
            text: "Fill the rest"
            onClicked: {
                text_precons.text   = "take arms against a sea of troubles,\nAnd by opposing end them"
                text_expres.text    = "To sleep: perchance to dream: ay, there's the rub;\nFor in that sleep of death what dreams may come\nWhen we have shuffled off this mortal coil,\nMust give us pause:"
                text_actres.text    = "Thus conscience does make cowards of us all;\n And thus the native hue of resolution\n Is sicklied o'er with the pale cast of thought,\n And enterprises of great pith and moment\n With this regard their currents turn awry,\n And lose the name of action.\n"
                text_add.text       = "Hamlet. Act V, Scene II\nAct-I, Scene-IV\nAct III, Scene I"
            }
        }
        Button {
            text: "Load"
            onClicked: {
                Util.restore(StandardPaths.cache);
            }
        }
        Button {
            text: "Save"
            onClicked: {
                shallSave()
            }
        }
    }
    Label {
        width:  parent.width - Theme.horizontalPageMargin * 2
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.secondaryColor
        font.italic: true
        font.pixelSize: Theme.fontSizeSmall
        text: "goodcnt: " + infoGoodCnt + " fullcnt: " + infoFullCnt + " state: " + page.state
    }
}


// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
