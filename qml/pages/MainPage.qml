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

    property bool infoComplete: false
    LanguageModel{id: languageModel}

    function validate() {
        if (text_title.length > 7
            && text_desc.text.length > 15
            && text_steps.text.length > 15
        ) {
            infoComplete = true
        } else {
            infoComplete = false
        }
    }
    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        Column { id: col
            width: parent.width
            PageHeader { id: header ; title: qsTr("Bug Info (%1)").arg(infoComplete ? qsTr("complete") : qsTr("incomplete"))
                description: (infoComplete)
                ? qsTr("Ready for posting")
                : qsTr("Please fill in the required fields")
            }
            Column {
                width: parent.width
                SectionHeader { text: "Title" + "*" }
                TextField{id: text_title; width: parent.width; placeholderText: "A New Bug Report"; onFocusChanged: validate()}
                SectionHeader { text: "Description" + "*" }
                TextArea{id: text_desc; width: parent.width; placeholderText: "Describe what is not working"; onFocusChanged: validate() }
            }
            Flow {
                width: parent.width
                Column {
                    width: parent.width /2
                    SectionHeader { text: "Device" }
                    DetailItem { label: "Name" ;            value: bugInfo.hw.name;}
                    DetailItem { label: "Device" ;          value: bugInfo.hw.id;}
                    DetailItem { label: "HA Device" ;       value: bugInfo.hw.mer_ha_device;}
                    DetailItem { label: "HA Version" ;      value: bugInfo.hw.version_id;}
                    //DetailItem { label: "Build" ;           value: bugInfo.hw.sailfish_build;}
                    //DetailItem { label: "Flavour" ;         value: bugInfo.hw.sailfish_flavour;}
                }
                Column {
                    width: parent.width/2
                    SectionHeader { text: "Operating System" }
                    DetailItem { label: "Name" ;            value: bugInfo.os.name;}
                    DetailItem { label: "OS Version" ;      value: bugInfo.os.version_id;}
                    DetailItem { label: "Code Name" ;            value: bugInfo.os.version.split("(")[1].replace(")","") }
                    DetailItem { label: "Arch" ;                 value: bugInfo.ssu.arch;}
                    //DetailItem { label: "Build" ;           value: bugInfo.os.sailfish_build;}
                    //DetailItem { label: "Flavour" ;         value: bugInfo.os.sailfish_flavour;}
                }
                /*
                Column {
                    width: parent.width
                    //width: parent.width/2
                    //SectionHeader { text: "Software" }
                    SectionHeader { text: "Other" }
                    DetailItem { label: "Arch" ;            value: bugInfo.ssu.arch;}
                    DetailItem { label: "Brand" ;           value: bugInfo.ssu.brand;}
                    //DetailItem { label: "Domain" ;          value: bugInfo.ssu.domain;}
                    //DetailItem { label: "Flavour" ;         value: bugInfo.ssu.flavour;}
                    //DetailItem { label: "Initialized" ;     value: bugInfo.ssu.initialized;}
                    //DetailItem { label: "Registered" ;      value: bugInfo.ssu.registered;}
                //}
                //Column {
                //    width: parent.width/2
                //    SectionHeader { text: "Other" }
                    DetailItem { label: "Current Locale"; value: Qt.locale().name}
                    //DetailItem { label: "System Locale"; value: languageModel.locale(languageModel.currentIndex)}
                    DetailItem { label: "System Language"; value: languageModel.languageName(languageModel.currentIndex)}
                }
                */
            }
            SectionHeader { text: "Prerequisites" }
            TextArea{id: text_prereq; width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge); placeholderText: "Some Context information,\ne.g. 'an email account is needed'."}
            SectionHeader { text: "Steps to Reproduce" + "*" }
            TextArea{id: text_steps; width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge); text: "1.\n2.\n3."; placeholderText: "1.\n2.\n3."; onFocusChanged: validate() }
            SectionHeader { text: "Expected Results" }
            TextArea{id: text_expres; width: parent.width; placeholderText: "What outcome did you expect"}
            SectionHeader { text: "Actual Results" }
            TextArea{id: text_actres; width: parent.width; placeholderText: "What was the outcome"}
            SectionHeader { text: "Additional Information" }
            TextArea{id: text_add; width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge); placeholderText: "Add any other information,\nsuch as links to logs or screenshots."}
            Slider { id: repro; width: parent.width; label: "Reproducibility"; minimumValue: 0; maximumValue: 100; stepSize: 10 ; valueText: (value <10) ? "never" : value + "%"; value: -1}
            TextSwitch { id: regsw; checked: false; text: "Regression (was working in a previous OS release)" }
            Column {
                width: parent.width
                SectionHeader { text: "Modifications" }
                TextSwitch { id: pmsw; enabled: false ; checked: bugInfo.mods.patchmanager; text: "Patchmanager (autodetected)" ; automaticCheck: false }
                TextSwitch { id: orsw; enabled: false ; checked: bugInfo.mods.openrepos;    text: "OpenRepos (autodetected)"; automaticCheck: false  }
                TextSwitch { id: chsw; enabled: false ; checked: bugInfo.mods.chum;         text: "Chum (autodetected)"; automaticCheck: false  }
                TextSwitch { id: othersw; checked: bugInfo.mods.other; text: "Other (please specify)" }
                TextField { id: text_mod_other; enabled: othersw.checked }
            }
        }
        VerticalScrollDecorator {}
    }
    PullDownMenu { id: pdm
        flickable: flick
        MenuItem { text: qsTr("About"); onClicked: { pageStack.push(Qt.resolvedUrl("AboutPage.qml")) } }
        //MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
    }
    PushUpMenu { id: pum
        flickable: flick
        MenuLabel { text: qsTr("Please fill in the required fields)") + " " + qsTr("(marked with an asterisk (*))!"); visible: !infoComplete; }
        MenuItem { text: qsTr("Post Bugreport");
            enabled: infoComplete
            onClicked: {
                var payload =
                    "REPRODUCIBILITY: " + repro.value + "%" + "  \n"
                    + "OSVERSION: " + bugInfo.os.version_id + "  \n"
                    + "HARDWARE: " + bugInfo.hw.name + " - " + bugInfo.hw.id + " - " + bugInfo.hw.mer_ha_device + " - " + bugInfo.hw.version_id + " - " + bugInfo.ssu.arch +  "  \n"
                    + "UI LANGUAGE: " + languageModel.languageName(languageModel.currentIndex) + " ( user: " + Qt.locale().name + ", os: " + languageModel.locale(languageModel.currentIndex) +")" + "  \n"
                    + "REGRESSION: " + regsw.checked + "  \n"
                    + "\n\n"
                    + "DESCRIPTION:\n"
                    + "=========\n\n" + text_desc.text
                    + "\n\n"
                    + "PREREQUISITES:\n"
                    + "==========\n\n" + text_prereq.text
                    + "\n\n"
                    + "EXPECTED RESULTS:\n"
                    + "============\n\n" + text_expres.text
                    + "\n\n"
                    + "ACTUAL RESULTS:\n"
                    + "===========\n\n" + text_actres.text
                    + "\n\n"
                    + "MODIFICATIONS:\n"
                    + "==========\n\n"
                    + " - Patchmanager: " + pmsw.checked + "  \n"
                    + " - OpenRepos: "    + orsw.checked + "  \n"
                    + " - Chum: "         + chsw.checked + "  \n"
                    + " - Other: "        + text_mod_other.text + "  \n"
                    + "\n\n"
                    + "ADDITIONAL INFORMATION:\n"
                    + "=================\n\n"
                    + "\n\n";
                var fullPostUrl = postUrl
                    + "&title=" + encodeURIComponent(text_title.text)
                    + "&body=" + encodeURIComponent(payload);
                console.debug("Opening ", fullPostUrl)
                Qt.openUrlExternally(fullPostUrl)
            }
        }
    }

}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
