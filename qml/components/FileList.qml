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

SilicaGridView { id: root
    property bool showPlaceholder: true
    property bool filtered: false
    width: parent.width
    height: Theme.iconSizeLarge * Math.max(count, 2)
    cellWidth: parent.width/2
    cellHeight: Theme.iconSizeLarge
    delegate: LogfileDelegate { hidden: ( root.filtered && (pastedUrl.length ==0)) }
    ViewPlaceholder {
        enabled: (root.count == 0) && showPlaceholder
        text: "No files."
        hintText: "Pull down to add log files."
    }
}
// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
