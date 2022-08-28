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

Flow {
    Column {
        width: parent.width /2
        SectionHeader { text: qsTr("Device") }
        DetailItem { label: "Name" ;            value: bugInfo.hw.name;}
        DetailItem { label: "Device" ;          value: bugInfo.hw.id;}
        DetailItem { label: "HA Device" ;       value: bugInfo.hw.mer_ha_device;}
        DetailItem { label: "HA Version" ;      value: bugInfo.hw.version_id;}
        //DetailItem { label: "Build" ;           value: bugInfo.hw.sailfish_build;}
        //DetailItem { label: "Flavour" ;         value: bugInfo.hw.sailfish_flavour;}

    }
    Column {
        width: parent.width/2
        SectionHeader { text: qsTr("Operating System") }
        DetailItem { label: "Name" ;            value: bugInfo.os.name;}
        DetailItem { label: "OS Version" ;      value: bugInfo.os.version_id;}
        DetailItem { label: "Code Name" ;       value: bugInfo.os.version.split("(")[1].replace(")","") }
        DetailItem { label: "Arch" ;            value: bugInfo.ssu.arch;}
        //DetailItem { label: "Build" ;           value: bugInfo.os.sailfish_build;}
        //DetailItem { label: "Build" ;           value: bugInfo.os.sailfish_build;}
        //DetailItem { label: "Flavour" ;         value: bugInfo.os.sailfish_flavour;}


    }
    Column {
        width: parent.width/2
        SectionHeader { text: qsTr("Other") }
        DetailItem { label: "Owner" ;           value: userInfo.username }
        DetailItem { label: "Encryption" ;      value: encStr ;}
    }
    Column {
        width: parent.width/2
        SectionHeader { text: qsTr("Locale") }
        DetailItem { label: "Current";   value: Qt.locale().name}
        DetailItem { label: "System";    value: languageModel.locale(languageModel.currentIndex)}
    }
    /*
    Column {
        width: parent.width
        SectionHeader { text: qsTr("Other") }
        DetailItem { label: "Arch" ;            value: bugInfo.ssu.arch;}
        DetailItem { label: "Brand" ;           value: bugInfo.ssu.brand;}
        //DetailItem { label: "Domain" ;          value: bugInfo.ssu.domain;}
        //DetailItem { label: "Flavour" ;         value: bugInfo.ssu.flavour;}
        //DetailItem { label: "Initialized" ;     value: bugInfo.ssu.initialized;}
        //DetailItem { label: "Registered" ;      value: bugInfo.ssu.registered;}

        DetailItem { label: "Current Locale";   value: Qt.locale().name}
        DetailItem { label: "Current Language"; value: Qt.locale().nativeLanguageName}
        DetailItem { label: "System Locale";    value: languageModel.locale(languageModel.currentIndex)}
        DetailItem { label: "System Language";  value: languageModel.languageName(languageModel.currentIndex)}
    }
*/
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
