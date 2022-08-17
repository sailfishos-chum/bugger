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
import "../components"

Page {
    id: page

    property bool infoComplete: false
    readonly property string infoFooter: '<!-- the initial version of this bug report was created using ' + Qt.application.name + " v" + Qt.application.version + ' -->'

    // from org.nemomobile.systemsettings to determine OS language
    LanguageModel{id: languageModel}
    // from org.nemomobile.systemsettings to determine Device Owner
    UserInfo{id: userInfo; uid: 100000}

    /* only allow somewhat complete reports to be posted */
    function validate() {
        // for testing/debugging:
        if ( Qt.application.name == "QtQmlViewer") {
            console.debug("disabled validation during testing.")
            infoComplete = true;
            return
        }
        if (text_title.length > 7
            && text_desc.text.length > 15
            && text_steps.text.length > 15
        ) {
            infoComplete = true
        } else {
            infoComplete = false
        }
    }

    /* show a welcome popup on launch */
    property bool welcomeShown: false
    onStatusChanged: {
        if (status == PageStatus.Active) showWelcomeDialog();
    }
    function showWelcomeDialog() {
        if (welcomeShown) return;
        var dialog = pageStack.push(Qt.resolvedUrl("../components/WelcomeDialog.qml"))
        dialog.done.connect(function() { page.welcomeShown = true })
    }
    /* welcome over */

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
            WelcomeLabel{
                width:  parent.width - Theme.horizontalPageMargin * 2
                clip: true
                Label {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: Theme.horizontalPageMargin
                    color: Theme.secondaryColor
                    font.italic: true
                    font.pixelSize: Theme.fontSizeTiny
                    text: qsTr("You can tap this section to hide it.")
                }
                property bool hide: false
                height: hide ? 0 : implicitHeight
                opacity: hide ? 0 : 1.0
                visible: height > 0
                Behavior on opacity { FadeAnimation{ duration: 1000; easing.type: Easing.OutQuart} }
                Behavior on height { PropertyAnimation{ duration: 600; easing.type: Easing.OutQuad} }
                BackgroundItem { anchors.centerIn: parent; anchors.fill: parent;
                    onClicked: {
                        parent.hide = true;
                    }
                }
            }
            Column {
                width: parent.width
                SectionHeader { text: qsTr("Title") + "*" }
                TextField{id: text_title; width: parent.width;
                    onFocusChanged: validate()
                    placeholderText: qsTr("A New Bug Report");
                    description: qsTr("Please be brief but descriptive");
                }
                SectionHeader { text: qsTr("Description") + "*" }
                TextArea{id: text_desc;
                    width: parent.width;
                    onFocusChanged: validate()
                    description: qsTr("Describe what is not working");
                }
                SectionHeader { text: qsTr("Steps to Reproduce") + "*" }
                TextArea{id: text_steps;
                    width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                    // description wraps the text, label fades it out.
                    //label: qsTr("Provide as much information as you have to reproduce the behavior")
                    label: qsTr("How to reproduce");
                    //description: qsTr("Provide as much information as you have to reproduce the behavior")
                    description: qsTr("Provide as much information as you have")
                    text: qsTr("1.\n2.\n3.");
                    placeholderText: qsTr("1.\n2.\n3.");
                    onFocusChanged: validate()
                }
            }
           SectionHeader { text: qsTr("Preconditions") }
            TextArea{id: text_precons;
                width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                //placeholderText: qsTr("e.g. 'an email account is needed'.")
                label: qsTr("Some Context information.")
                description: qsTr("e.g. 'an email account is needed'.")
            }

            SectionHeader { text: qsTr("Expected Results") }
            TextArea{id: text_expres;
                width: parent.width;
                label: qsTr("What outcome did you expect")
                description: qsTr("e.g. 'an error notification', 'a message is shown'")
            }
            SectionHeader { text: qsTr("Actual Results") }
            TextArea{id: text_actres;
                width: parent.width;
                //placeholderText: qsTr("What was the outcome")
                label: qsTr("What was the outcome")
                description: qsTr("e.g. 'the app closed', 'a message was not shown'")
            }
            SectionHeader { text: qsTr("Device Information") }
            Separator { color: Theme.primaryColor; horizontalAlignment: Qt.AlignHCenter; width: page.width}
            Flow { id: devflow
                width: parent.width
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
                    DetailItem { label: "Code Name" ;            value: bugInfo.os.version.split("(")[1].replace(")","") }
                    DetailItem { label: "Arch" ;                 value: bugInfo.ssu.arch;}
                    //DetailItem { label: "Build" ;           value: bugInfo.os.sailfish_build;}
                    //DetailItem { label: "Build" ;           value: bugInfo.os.sailfish_build;}
                    //DetailItem { label: "Flavour" ;         value: bugInfo.os.sailfish_flavour;}

                    DetailItem { label: "Owner" ;      value: userInfo.username }
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
            Separator { color: Theme.primaryColor; horizontalAlignment: Qt.AlignHCenter; width: page.width}
            SectionHeader { text: qsTr("Additional Information") }
            TextArea{id: text_add;
                width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                label: qsTr("Add any other information")
                description: qsTr("e.g. links to logs or screenshots.")
            }
            Slider { id: repro;
                width: parent.width;
                label: qsTr("Reproducibility");
                minimumValue: 0; maximumValue: 100; stepSize: 25 ; value: -1
                valueText: qsTr(userTextL10N)
                property string userText: {
                    if (value <= 0) return "not specified"
                    if (value <= 25) return "never"
                    if (value <= 50) return "sometimes"
                    if (value <= 75) return "often"
                    return "always"
                }
                property string userTextL10N: {
                    if (value <= 0) return qsTr("not specified", "Reproducibility")
                    if (value <= 25) return qsTr("never",         "Reproducibility")
                    if (value <= 50) return qsTr("sometimes",     "Reproducibility")
                    if (value <= 75) return qsTr("often",         "Reproducibility")
                    return qsTr("always", "Reproducibility")
                }
            }
            TextSwitch { id: regsw; checked: false;
                text: qsTr("Regression (was working in a previous OS release)")
            }
            Column {
                width: parent.width - Theme.horizontalPageMargin
                SectionHeader { text: qsTr("Modifications") }
                TextSwitch { id: pmsw; checked: bugInfo.mods.patchmanager; text: "Patchmanager" + " " + qsTr("(autodetected)"); automaticCheck: false; highlighted: false; }
                TextSwitch { id: orsw; checked: bugInfo.mods.openrepos;    text: "OpenRepos"    + " " + qsTr("(autodetected)"); automaticCheck: false; highlighted: false; }
                TextSwitch { id: chsw; checked: bugInfo.mods.chum;         text: "Chum"+ " "    + " " + qsTr("(autodetected)"); automaticCheck: false; highlighted: false; }
                TextSwitch { id: othersw; checked: false; text: qsTr("Other (please specify)") }
                TextField { id: text_mod_other; enabled: othersw.checked
                    // this has no label...
                    placeholderText: qsTr("e.g. WayDroid and GApps installed")
                    description: qsTr("custom changes, installed packages etc.")
                }
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
        MenuLabel { text: qsTr("Please fill in the required fields") + " " + qsTr("(marked with an asterisk (*))!"); visible: !infoComplete; }
        MenuItem { text: qsTr("Post Bug Report");
            enabled: infoComplete
            onClicked: {
                var payload =
                    "REPRODUCIBILITY: " + repro.sliderValue + "%" + " (" + repro.userText + ")"+ "  \n"
                    + "OSVERSION: " + bugInfo.os.version_id + "  \n"
                    + "HARDWARE: " + bugInfo.hw.name + " - " + bugInfo.hw.id + " - " + bugInfo.hw.mer_ha_device + " - " + bugInfo.hw.version_id + " - " + bugInfo.ssu.arch +  "  \n"
                    + "UI LANGUAGE: " + languageModel.languageName(languageModel.currentIndex) + " ( user: " + Qt.locale().name + ", os: " + languageModel.locale(languageModel.currentIndex) +" )" + "  \n"
                    + "REGRESSION: " + regsw.checked + "  \n"
                    + "\n\n"
                    + "DESCRIPTION:\n"
                    + "=========\n\n" + text_desc.text
                    + "\n\n"
                    + "PRECONDITIONS:\n"
                    + "==========\n\n" + text_precons.text
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
                    + "=================\n\n" + text_add.text
                    + "\n\n"
                    + infoFooter + "\n"
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
