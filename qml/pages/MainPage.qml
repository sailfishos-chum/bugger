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
import org.nemomobile.systemsettings 1.0

Page {
    id: page

    LanguageModel{id: languageModel}

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        Column { id: col
            width: parent.width
            PageHeader { id: header ; title: qsTr("Bug Info") }
            //Label { text: JSON.stringify(bugInfo.mods,null,4) }
            Flow {
                width: parent.width
                Column {
                    width: parent.width /2
                    SectionHeader { text: "Device" }
                    DetailItem { label: "Name" ;            value: bugInfo.hw.name;}
                    DetailItem { label: "Device" ;          value: bugInfo.hw.id;}
                    DetailItem { label: "HA Device" ;       value: bugInfo.hw.mer_ha_device;}
                    DetailItem { label: "HA Version" ;      value: bugInfo.hw.version_id;}
                    DetailItem { label: "Build" ;           value: bugInfo.hw.sailfish_build;}
                    DetailItem { label: "Flavour" ;         value: bugInfo.hw.sailfish_flavour;}
                }
                Column {
                    width: parent.width/2
                    SectionHeader { text: "Sailfish OS" }
                    DetailItem { label: "Name" ;            value: bugInfo.os.name;}
                    DetailItem { label: "OS Version" ;      value: bugInfo.os.version_id;}
                    DetailItem { label: "Code Name" ;            value: bugInfo.os.version.split("(")[1].replace(")","") }
                    DetailItem { label: "Build" ;           value: bugInfo.os.sailfish_build;}
                    DetailItem { label: "Flavour" ;         value: bugInfo.os.sailfish_flavour;}
                }
                //Label { text: JSON.stringify(bugInfo.os,null,4) }
                Column {
                    width: parent.width/2
                    SectionHeader { text: "Software" }
                    DetailItem { label: "Arch" ;            value: bugInfo.ssu.arch;}
                    DetailItem { label: "Brand" ;           value: bugInfo.ssu.brand;}
                    DetailItem { label: "Domain" ;          value: bugInfo.ssu.domain;}
                    DetailItem { label: "Flavour" ;         value: bugInfo.ssu.flavour;}
                    DetailItem { label: "Initialized" ;     value: bugInfo.ssu.initialized;}
                    DetailItem { label: "Registered" ;      value: bugInfo.ssu.registered;}
                }
                //Label { text: JSON.stringify(bugInfo.ssu,null,4) }
                Column {
                    width: parent.width/2
                    SectionHeader { text: "Other" }
                    DetailItem { label: "Current Locale"; value: Qt.locale().name}
                    DetailItem { label: "System Locale"; value: languageModel.locale(languageModel.currentIndex)}
                    DetailItem { label: "System Language"; value: languageModel.languageName(languageModel.currentIndex)}
                }
            }
            SectionHeader { text: "Title" }
            TextField{width: parent.width}
            SectionHeader { text: "Description" }
            TextArea{width: parent.width}
            SectionHeader { text: "Steps to Reproduce" }
            TextArea{width: parent.width}
            SectionHeader { text: "Results" }
            TextArea{width: parent.width}
            SectionHeader { text: "Expected Results" }
            TextArea{width: parent.width}
            SectionHeader { text: "Additional Information" }
            TextArea{width: parent.width}
            Column {
                width: parent.width
                SectionHeader { text: "Modifications" }
                TextSwitch { enabled: false ; checked: bugInfo.mods.patchmanager; text: "Patchmanager (autodetected)" ; automaticCheck: false }
                TextSwitch { enabled: false ; checked: bugInfo.mods.openrepos;    text: "OpenRepos (autodetected)"; automaticCheck: false  }
                TextSwitch { enabled: false ; checked: bugInfo.mods.chum;         text: "Chum (autodetected)"; automaticCheck: false  }
                TextSwitch { id: othersw; checked: bugInfo.mods.other; text: "Other (please specify)" }
                TextField { enabled: othersw.checked }
            }
        }
        VerticalScrollDecorator {}
    }
    PullDownMenu { id: pdm
        flickable: flick
        MenuItem { text: qsTr("About"); onClicked: { pageStack.push(Qt.resolvedUrl("AboutPage.qml")) } }
        //MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
        MenuItem { text: qsTr("Post Bugreport");
            onClicked: {
                console.debug("Opening ", postUrl)
                Qt.openUrlExternally(postUrl)
            }
        }
    }

}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
