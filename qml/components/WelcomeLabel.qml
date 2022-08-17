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

Label {
    anchors.horizontalCenter: parent.horizontalCenter
    color: Theme.secondaryHighlightColor
    font.pixelSize: Theme.fontSizeSmall
    horizontalAlignment: Text.AlignJustify
    wrapMode: Text.WordWrap
    // show a notice for non-English app locales:
    text: (Qt.locale().name.search(/^en/) !== -1) ? standardText : standardText + l10nnotice
    property string l10nnotice: qsTr('Notice: Even though %1 offers localized versions, please keep your bug report contents in English if at all possible.').arg(Qt.application.name)
    property string standardText: qsTr('
Please fill out the information about your bug in the fields of the main page.
After this in completed, you will be able to post your bug report in the Pulley Menu at the bottom.

Your bug report will be opened in the browser in draft mode so you can edit it before doing the final post.

We recommend having a browser window open and logged into the Sailfish OS Forum before posting.
')
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
