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
import org.nemomobile.systemsettings 1.0
import "../components"
import "../config/settings.js" as Settings
import "../js/util.js" as Util

Page {
    id: page

    /* config constants: */
    readonly property int minTitleLength:   Settings.config.validation.minTitle
    readonly property int minDescLength:    Settings.config.validation.minDesc
    readonly property int minStepsLength:   Settings.config.validation.minSteps
    readonly property int goodLength:       Settings.config.validation.good

    /* Conditions for minimum information required for posting */
    property bool infoComplete: ( titleComplete && descComplete && stepsComplete )
    property bool titleComplete: text_title.acceptableInput
    property bool descComplete:  text_desc.acceptableInput
    property bool stepsComplete: text_steps.acceptableInput

    /* Conditions (more or less random heuristics) to judge a report as "good" */
    property bool infoGood: ((infoGoodCnt > goodLength) && (infoGoodCnt > infoFullCnt) && (repro.value != -1));
    property bool infoFull: infoGood && (infoFullCnt > goodLength)
    property int infoGoodCnt:
        1 * text_desc.text.length +
        1 * text_steps.text.length +
        1 * text_precons.text.length +
        1 * text_expres.text.length +
        1 * text_actres.text.length +
        0
    property int infoFullCnt:
        1 * text_precons.text.length +
        1 * text_expres.text.length +
        1 * text_actres.text.length +
        0
    readonly property string infoFooter: 'the initial version of this bug report was created using ' + Qt.application.name + " v" + Qt.application.version

    // from org.nemomobile.systemsettings to determine Device Owner
    UserInfo{id: userInfo; uid: 100000}
    // from org.nemomobile.systemsettings to determine OS language
    LanguageModel{id: languageModel}
    property string oslanguage:  languageModel.languageName(languageModel.currentIndex)
    property string uilocale:    Qt.locale().name
    property string oslocale:    languageModel.locale(languageModel.currentIndex)

    onOslanguageChanged: console.info("Detected OS Language:", oslanguage)
    onOslocaleChanged:   console.info("Detected OS Locale:",   oslocale)

     /* handle different states of completeness */
    states: [
        // "" =  default  = incomplete
        State { name: "incomplete"
            PropertyChanges { target: header;
                title:          qsTr("Bug Info (%1)").arg(qsTr("incomplete", "State of completeness of a bug report"))
            }
        },
        State { name: "titleMissing";   when: (!infoComplete && !titleComplete)
            PropertyChanges { target: header;
                description: qsTr("%1 field is too short").arg(qsTr("Title")) + " (" + text_title.text.length + "/" + minTitleLength + ")"
            }
        },
        State { name: "descMissing";    when: (!infoComplete && !descComplete)
            PropertyChanges { target: header;
                description: qsTr("%1 field is too short").arg(qsTr("Description")) + " (" + text_desc.text.length + "/" + minDescLength + ")"
            }
        },
        State { name: "stepsMissing";   when: (!infoComplete && !stepsComplete)
            PropertyChanges { target: header;
                description: qsTr("%1 field is too short").arg(qsTr("Steps")) + " (" + text_steps.text.length + "/" + minStepsLength + ")"
            }
        },
        State { name: "complete";       when: (infoComplete && !infoGood && !infoFull )
            PropertyChanges { target: header;
                title:          qsTr("Bug Info (%1)").arg(qsTr("ok", "State of completeness of a bug report"))
                description:    qsTr("Ready for posting") + qsTr(", but please add more information")
            }
        },
        State { name: "good";       when: (infoComplete && infoGood && !infoFull)
            PropertyChanges { target: header;
                title:          qsTr("Bug Info (%1)").arg(qsTr("good", "State of completeness of a bug report"))
                description:    qsTr("Ready for posting")
            }
        },
        State { name: "full";       when: (infoComplete && infoFull)
            PropertyChanges { target: header;
                title:          qsTr("Bug Info (%1)").arg(qsTr("complete", "State of completeness of a bug report"))
                description:    qsTr("Ready for posting")
            }
        }
    ]

    /*
     * ***** WELCOME DIALOG *****
     *
     * show a welcome popup on launch
     */
    property bool welcomeShown: false
    onStatusChanged: {
        if (status == PageStatus.Active) showWelcomeDialog();
    }
    function showWelcomeDialog() {
        if (welcomeShown) return;
        if (developerMode) return;
        var dialog = pageStack.push(Qt.resolvedUrl("../components/WelcomeDialog.qml"))
        dialog.done.connect(function() { page.welcomeShown = true;})
    }
    /* END WELCOME DIALOG */

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        Column { id: col
            width: parent.width
            PageHeader { id: header ; title: qsTr("Bug Info (%1)").arg(qsTr("incomplete", "State of completeness of a bug report")) }
            /* tap-to-hide information */
            SilicaItem { id: hidetext
                width:  parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                property bool hide: false
                height: hide ? 0 : (lblcol.height + dismisslbl.height)
                opacity: hide ? 0 : 1.0
                visible: height > 0
                Behavior on opacity { FadeAnimation{ duration: 1000; easing.type: Easing.OutQuart} }
                Behavior on height { PropertyAnimation{ duration: 600; easing.type: Easing.OutQuad} }
                Column { id: lblcol
                    width:  parent.width
                    WelcomeLabel { }
                    L10NNotice{ visible: !(/^en/.test(uilocale)) }
                }
                Label { id: dismisslbl
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: Theme.secondaryColor
                    font.italic: true
                    font.pixelSize: Theme.fontSizeTiny
                    text: qsTr("You can tap this section to hide it.")
                }
                BackgroundItem { anchors.centerIn: parent; anchors.fill: parent;
                    onClicked: {
                        parent.hide = true;
                    }
                }
            }
            /* Testing Helper */
            Loader {
                width: parent.width
                active: developerMode
                sourceComponent: DeveloperTool {}
            }
            /*****************************
             * Required fields at the top
             *****************************/
            Column { id: reqFieldCol
                width: parent.width
                SectionHeader { text: qsTr("Title") + "*" }
                TextField{id: text_title; width: parent.width;
                    placeholderText: qsTr("A New Bug Report");
                    description: qsTr("Please be brief but descriptive");
                    acceptableInput: text.length > minTitleLength
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: text_desc.focus = true
                }
                SectionHeader { text: qsTr("Description") + "*" }
                TextArea{id: text_desc;
                    width: parent.width;
                    description: qsTr("Describe what is not working");
                    // TextField has this, TextArea not:
                    property bool acceptableInput: text.length > minDescLength
                }
                SectionHeader { text: qsTr("Steps to Reproduce") + "*" }
                TextArea{id: text_steps;
                    width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                    // description wraps the text, label fades it out.
                    //label: qsTr("Provide as much information as you have to reproduce the behavior")
                    label: qsTr("How to reproduce");
                    //description: qsTr("Provide as much information as you have to reproduce the behavior")
                    description: qsTr("Provide as much information as you have")
                    text: " 1. \n 2. \n 3. ";
                    placeholderText: " 1. \n 2. \n 3. ";
                    // TextField has this, TextArea not:
                    property bool acceptableInput: text.length > minStepsLength
                }
            }
           SectionHeader { text: qsTr("Preconditions") }
            TextArea{id: text_precons;
                width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                //placeholderText: qsTr("e.g. 'an email account is needed'.")
                label: qsTr("Some Context information")
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
            /* 
             * bug info contents may be available later than this page is instantiated.
             * So use a Loader to quiet the "undefined" errors in the log.
             *
             * TODO: I'm sure there is a more QMLy way of doing this buut I never quite understood Binding{}
             */
            Loader {
                width: parent.width
                active: (typeof bugInfo.hw !== "undefined") && (typeof bugInfo.os !== "undefined") && (typeof bugInfo.ssu !== "undefined")
                sourceComponent: DeviceInfo{}
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
                // this goes into the bug report
                property string userText: {
                    if (value == -1) return "not specified"
                    if (value == 0)  return "unknown"
                    if (value <= 25) return "never"
                    if (value <= 50) return "sometimes"
                    if (value <= 75) return "often"
                    return "always"
                }
                // this is just for translation/presentation
                property string userTextL10N: {
                    if (value == -1) return ""
                    if (value == 0)  return qsTr("unknown",        "Reproducibility")
                    if (value <= 25) return qsTr("never",          "Reproducibility")
                    if (value <= 50) return qsTr("sometimes",      "Reproducibility")
                    if (value <= 75) return qsTr("often",          "Reproducibility")
                    return qsTr("always", "Reproducibility")
                }
            }
            TextSwitch { id: regsw; checked: false;
                text: qsTr("Regression (was working in a previous OS release)")
                automaticCheck: false
                onClicked: {
                    checked = !checked;
                    if (!checked) {
                        regver.currentIndex  = -1
                        regarch.currentIndex = -1
                    }
                }
            }
            VersionSelect { id: regver;  state: "version"; visible: regsw.checked; anchors.left: regsw.left ; anchors.leftMargin: Theme.itemSizeExtraSmall - Theme.paddingLarge }
            VersionSelect { id: regarch; state: "arch";    visible: regsw.checked; anchors.left: regsw.left ; anchors.leftMargin: Theme.itemSizeExtraSmall - Theme.paddingLarge }
            Column {
                width: parent.width
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
        MenuItem { text: qsTr("Reset all to default"); onDelayedClick: { Remorse.popupAction(page, qsTr("Cleared."), function() { resetFields() }) } }
        //MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
    }
    PushUpMenu { id: pum
        flickable: flick
        busy: infoComplete
        MenuLabel { text: qsTr("Please fill in the required fields") + " " + qsTr("(marked with an asterisk (*))!"); visible: !infoComplete; }
        MenuLabel { text: qsTr("%1 field is incomplete").arg(qsTr("Title"))       ; visible: ( !infoComplete && !titleComplete); }
        MenuLabel { text: qsTr("%1 field is incomplete").arg(qsTr("Description")) ; visible: ( !infoComplete && !descComplete); }
        MenuLabel { text: qsTr("%1 field is incomplete").arg(qsTr("Steps"))       ; visible: ( !infoComplete && !stepsComplete); }
        MenuItem { text: qsTr("Post Bug Report");
            enabled: infoComplete
            onClicked: {
                var fullPostUrl = formToUrl();
                console.debug("Opening ", fullPostUrl);
                Qt.openUrlExternally(fullPostUrl);
            }
        }
    }

   /*
    * ****** POSTING *****
    *
    * convert the form fields into a bug report post
    *
    * */
    function getPayload() {
        var payload =
            "REPRODUCIBILITY: " + repro.sliderValue + "%" + " (" + repro.userText + ")"+ "  \n"
            + "OSVERSION: " + bugInfo.os.version_id + "  \n"
            + "HARDWARE: " + bugInfo.hw.name + " - " + bugInfo.hw.id + " - " + bugInfo.hw.mer_ha_device + " - " + bugInfo.hw.version_id + " - " + bugInfo.ssu.arch +  "  \n"
            + "UI LANGUAGE: " + oslanguage + " (user: " + uilocale + ", os: " + oslocale + ")" + "  \n"
            + "REGRESSION: " + (regsw.checked?"yes":"no")
            + ( regsw.checked
                ? " (since: " + ((!!regver.value) ? regver.value : "n/a") + " - " + ((!!regarch.value) ? regarch.value : "n/a") + ")"
                : ""
            )
            + "  \n"
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
            + " - Patchmanager: " + (pmsw.checked?"yes":"no") + "  \n"
            + " - OpenRepos: "    + (orsw.checked?"yes":"no") + "  \n"
            + " - Chum: "         + (chsw.checked?"yes":"no") + "  \n"
            + " - Other: "        + text_mod_other.text + "  \n"
            + "\n\n"
            + "ADDITIONAL INFORMATION:\n"
            + "=================\n\n" + text_add.text
            + "\n\n\n\n"
            // add footer:
            + "----  \n" 
            + "*" + infoFooter + "*\n"
            + "";
        return payload;
    }
    /* just to be consistent */
    function getTitle() {
        return text_title.text;
    }
    /* encode the payload, return full URL for posting */
    function formToUrl() {
        var fullPostUrl = postUrl
            + "&title=" + encodeURIComponent(getTitle())
            + "&body=" +  encodeURIComponent(getPayload());
        return fullPostUrl
    }
   /* ****** END POSTING ***** */

    // to be called from Pulley Menu
    // TODO: we could construct an object with the default data, and use restoreFields() instead.
    function resetFields() {
        preventSave = true;
        text_title.text         = "";
        text_desc.text          = "";
        text_steps.text         = " 1. \n 2. \n 3. ";
        text_precons.text       = "";
        text_expres.text        = "";
        text_actres.text        = "";
        text_add.text           = "";
        text_mod_other.text     = "";
        regsw.checked           = false;
        regver.currentIndex     = -1;
        regarch.currentIndex    = -1;
        othersw.checked         = false;
        repro.value             = -1;
        text_title.focus        = true;
        preventSave = false;
    }

   /*
    * ****** AUTOSAVE AND RESTORE *****
    *
    * save input on state changes, and when minimized
    */
    signal shallSave()
    property bool preventSave: false // prevent state changes triggering a save, e.g. a form reset
    Connections {
        target: app
        function onApplicationActiveChanged() {
            if (!Qt.application.active) {
                console.debug("deactivating, emitting shallSave");
                shallSave()
            }
        }
    }
    /* maybe save when the State changes */
    onStateChanged: {
        console.debug("state changed, emitting shallSave");
        shallSave()
    }

    /* prevent write bursts */
    Timer { id: backOffTimer
        interval: 100
        running: false
        repeat: false
    }
    /*
    Timer { id: saveTimer
        interval: 11000
        running: Qt.application.active
        repeat: true
        onTriggered: {
            console.debug("timer triggered");
            console.debug("emitting shallSave");
            shallSave()
        }
        onRunningChanged: console.debug("timer %1".arg(running ? "started" : "stopped"));
    }
    */
    // Signal Handler for shallSave
    onShallSave: {
        console.debug("got shall save");
        if (preventSave) {
            console.debug("saving disabled.");
            return;
        }
        if (backOffTimer.running) {
            console.debug("write within backoff period.");
            return;
        }
        // don't overwrite old data with worse data
        if (infoComplete || titleComplete || descComplete || stepsComplete ) {
            saveFields();
            backOffTimer.start();
        } else {
            console.debug("nothing worth saving");
        }
    }
    function saveFields() {
        const post = {};
        post.fields = {
            "text_title":       text_title.text,
            "text_desc":        text_desc.text,
            "text_steps":       text_steps.text,
            "text_precons":     text_precons.text,
            "text_expres":      text_expres.text,
            "text_actres":      text_actres.text,
            "text_add":         text_add.text,
            "text_mod_other":   text_mod_other.text,
            "regsw":            regsw.checked,
            "regver":           regver.currentIndex,
            "regarch":          regarch.currentIndex,
            "othersw":          othersw.checked,
            "repro":            repro.sliderValue
        };
        Util.store(StandardPaths.cache, post);
    }

    /*
     * As the loading Request is asynchronous, we don't know when the data is ready.
     *
     * So we create an object we can register at Util.js, and call a
     * signal/signal handler from there when the data is available
     *
     */
    QtObject { id: loadManager
        signal dataLoaded(var data)
        onDataLoaded: {
            console.debug("Handler called", data);
            var fields = JSON.parse(data).fields
            page.restoreFields(fields);
        }
        // regiter ourselves as the caller, and call the loading function
        function restore() {
            Util.registerCaller(loadManager);
            Util.restore(StandardPaths.cache);
        }
    }
    /*
     * set the form fields from an object
     */
    function restoreFields(data) {
        console.debug("Restoring fields");
        text_title.text         = data.text_title;
        text_desc.text          = data.text_desc;
        text_steps.text         = data.text_steps;
        text_precons.text       = data.text_precons;
        text_expres.text        = data.text_expres;
        text_actres.text        = data.text_actres;
        text_add.text           = data.text_add;
        text_mod_other.text     = data.text_mod_other;
        regsw.checked           = data.regsw;
        regver.currentIndex     = data.regver;
        regarch.currentIndex    = data.regarch;
        othersw.checked         = data.othersw;
        repro.value             = data.repro;
    }
   /* ****** END AUTOSAVE AND RESTORE ***** */


}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
