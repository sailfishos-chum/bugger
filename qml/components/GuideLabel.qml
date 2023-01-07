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

LinkedLabel {
    anchors.horizontalCenter: parent.horizontalCenter
    color: Theme.secondaryColor
    font.pixelSize: Theme.fontSizeSmall
    horizontalAlignment: Text.AlignJustify
    wrapMode: Text.WordWrap
    shortenUrl: true
    plainText: qsTr('
Please review the guidelines and follow the template when creating a bug report.

Guidelines: https://forum.sailfishos.org/t/22

If you are uncertain about how to fill out the report, we recommend asking about your issue in the General category of the Forum first:

General: https://forum.sailfishos.org/c/15

Information about debugging and collecting logs can be found here:

Testing: https://docs.sailfishos.org/Develop/Platform/Testing_Advice/

Wiki: https://forum.sailfishos.org/t/12751/3
')
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
