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

/* 
 * object to collect all the info read from files.
 * we could use a proper QML type for this, but this works
 */
QtObject { id: bugInfo
    property var hw
    property var os
    property var ssu
    property var mods: QtObject {
        property bool patchmanager: false
        property bool openrepos:    false
        property bool chum:         false
    }
    function setOs(o) { os = o }
    function setHw(o) { hw = o }
    function setSsu(o) { ssu = o }
    function setMod(s) { mods[s] = true }
}

// vim: ft=javascript expandtab ts=4 sw=4 st=4
