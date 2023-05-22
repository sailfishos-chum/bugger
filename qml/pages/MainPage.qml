/*

Apache License 2.0

Copyright (c) 2022,2023 Peter G. (nephros)

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
import org.nemomobile.devicelock 1.0
import org.nemomobile.systemsettings 1.0
import org.nemomobile.ngf 1.0
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

    /* IMPORTANT: remember to update this if any persisting UI elements are added on this page! */
    readonly property int fieldKeys:        Settings.config.persistence.fieldKeys
    /* saveTimer timeout */
    readonly property int saveInterval:     Settings.config.persistence.saveInterval

    /* Conditions for minimum information required for posting */
    property bool infoComplete: ( titleComplete && descComplete && stepsComplete )
    property bool titleComplete: text_title.acceptableInput
    property bool descComplete:  text_desc.acceptableInput
    property bool stepsComplete: text_steps.acceptableInput

    /* Conditions (more or less random heuristics) to judge a report as "good" */
    // good: sum of all fields greater than good limit
    // full: sum of optional fields greater than good limit, and repro specified
    property bool infoGood: infoComplete && (infoGoodCnt > goodLength)
    property bool infoFull: infoGood && (infoFullCnt > goodLength) && (repro.value != -1)
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
    property string qualityString//: qsTr("incomplete", "State of completeness of a bug report")

    /* just to add something of ours to the report */
    readonly property string infoFooter: 'the initial version of this bug report was created using '
        + '<a href="' + 'https://github.com/sailfishos-chum/bugger/releases/' + Qt.application.version + '">'
        + Qt.application.name + ' ' + Qt.application.version
        + '</a>'

    property var metatags: {
        "version":  Qt.application.version,
    }
    function metatagsToComment() {
        const comm = [
            "<!--",
            "The following tags are metadata for automated processing. Please leave them as-is and ignore them.",
        ]
        const keys  = Object.keys(metatags)
        const truth = [];
        keys.forEach(function(k) {
            comm.push("<x-bugger-meta name='" + k + "' value='" + metatags[k] + "' />")
            truth.push(metatags[k]);
        })
        const tamperhash = Qt.md5(truth.join("\n"));
        comm.push("<x-bugger-meta name='hash' value='" + tamperhash + "' />")
        comm.push("-->\n")
        return comm.join('\n')
    }

    // used to clear this form, and the persistent storage
    property var defaultFieldContents: {
        "text_title":       "",
        "text_desc":        "",
        "text_steps":       " 1. \n 2. \n 3. ",
        "text_precons":     "",
        "text_expres":      "",
        "text_actres":      "",
        "text_add":         "",
        "text_mod_other":   "",
        "regsw":            false,
        "regsw.hasChanged": false,
        "regver":           -1,
        "regarch":          -1,
        "othersw":          false,
        "repro":            -1
    }

    // Pavlov!! :)
    NonGraphicalFeedback { id: postiveFeedback; event: "positive_confirmation" }

    /*
     * ***** DATA SOURCES *****
     *
     * to autodetect some values for the report
     */
    /* from org.nemomobile.devicelock  to determine Home Encryption */
    EncryptionSettings{id: enc}
    property bool encryption: enc.homeEncrypted
    property string encStr: "not supported"
    onEncryptionChanged: {
        console.info("Detected encryption:",   encryption)
        if (typeof encryption !== "undefined") {
            encStr = encryption ? "enabled" : "disabled";
        } else {
            encStr = "not detected";
        }
    }

    // from org.nemomobile.systemsettings to determine Device Owner
    UserInfo{id: userInfo; uid: 100000}
    // from org.nemomobile.systemsettings to determine OS language
    LanguageModel{id: languageModel}
    property string oslanguage:  languageModel.languageName(languageModel.currentIndex)
    property string uilocale:    Qt.locale().name
    property string oslocale:    languageModel.locale(languageModel.currentIndex)

    onOslanguageChanged: console.info("Detected OS Language:", oslanguage)
    onOslocaleChanged:   console.info("Detected OS Locale:",   oslocale)
    /* ***** END DATA SOURCES ***** */


    /*
     * ***** PAGE INITIALIZATION *****
     *
     */

    /* load persistent store of form data */
    Component.onCompleted: {
        restoreSaved();
        preventSave = false;
    }

    /* handle different states of completeness */
    states: [
        // "" =  default = incomplete
        State { name: "incomplete";  when: (!infoComplete && !titleComplete && !descComplete && !stepsComplete)
            PropertyChanges { target: header;
                description: qsTr("Please fill in the required fields")
            }
            PropertyChanges { target: page; qualityString: qsTr("incomplete", "State of completeness of a bug report") }
        },
        State { name: "titleMissing";   when: (!infoComplete && !titleComplete)
            PropertyChanges { target: header;
                description: qsTr("%1 field is too short").arg(qsTr("Title")) + " (" + text_title.text.length + "/" + minTitleLength + ")"
            }
            PropertyChanges { target: page; qualityString: qsTr("incomplete", "State of completeness of a bug report") }
        },
        State { name: "descMissing";    when: (!infoComplete && !descComplete)
            PropertyChanges { target: header;
                description: qsTr("%1 field is too short").arg(qsTr("Description")) + " (" + text_desc.text.length + "/" + minDescLength + ")"
            }
            PropertyChanges { target: page; qualityString: qsTr("incomplete", "State of completeness of a bug report") }
        },
        State { name: "stepsMissing";   when: (!infoComplete && !stepsComplete)
            PropertyChanges { target: header;
                description: qsTr("%1 field is too short").arg(qsTr("Steps")) + " (" + text_steps.text.length + "/" + minStepsLength + ")"
            }
            PropertyChanges { target: page; qualityString: qsTr("incomplete", "State of completeness of a bug report") }
        },
        State { name: "complete";       when: (infoComplete && !infoGood && !infoFull )
            PropertyChanges { target: header;
                description:    qsTr("Ready for posting") + qsTr(", but please add more information")
            }
            PropertyChanges { target: page; qualityString: qsTr("ok", "State of completeness of a bug report") }
        },
        State { name: "good";       when: (infoGood && !infoFull)
            PropertyChanges { target: header;
                description:    qsTr("Ready for posting")
            }
            PropertyChanges { target: page; qualityString: qsTr("good", "State of completeness of a bug report") }
        },
        State { name: "full";       when: (infoFull)
            PropertyChanges { target: header;
                description:    qsTr("Ready for posting")
            }
            PropertyChanges { target: page; qualityString: qsTr("excellent", "State of completeness of a bug report") }
        }
    ]
    onStateChanged: {
        /* Maybe save when the State changes. 
         * Whether we actually will save is determined in the signal handler */
        shallSave();
    }
    onQualityStringChanged: {
        onCategoryChanged: metatags["qualityname"] = state;
        onCategoryChanged: metatags["qualityrating"] = infoGoodCnt;
        if ( state === "good" || state === "full" ) {
            postiveFeedback.play()
            app.popup(qsTr("Achievement unlocked! The quality of your bug report is %1!").arg(page.qualityString));
        }
    }

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
            PageHeader { id: header ; title: qsTr("Bug Info (%1)").arg(qualityString) }
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
                    // description wraps the text, label fades it out.
                    description: qsTr("Please be brief but descriptive");
                    acceptableInput: text.length > minTitleLength
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: text_desc.focus = true
                    onFocusChanged: shallSave();
                }
                SectionHeader { text: qsTr("Description") + "*" }
                TextArea{id: text_desc;
                    width: parent.width;
                    // description wraps the text, label fades it out.
                    description: qsTr("Describe what is not working");
                    // TextField has this, TextArea not:
                    property bool acceptableInput: text.length > minDescLength
                    onFocusChanged: shallSave();
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
                    onFocusChanged: shallSave();
                }
            }
           SectionHeader { text: qsTr("Preconditions") }
            TextArea{id: text_precons;
                width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                label: qsTr("Some Context information")
                description: qsTr("e.g. 'an email account is needed'.")
                onFocusChanged: shallSave();
            }

            SectionHeader { text: qsTr("Expected Results") }
            TextArea{id: text_expres;
                width: parent.width;
                label: qsTr("What outcome did you expect")
                description: qsTr("e.g. 'an error notification', 'a message is shown'")
                onFocusChanged: shallSave();
            }
            SectionHeader { text: qsTr("Actual Results") }
            TextArea{id: text_actres;
                width: parent.width;
                label: qsTr("What was the outcome")
                description: qsTr("e.g. 'the app closed', 'a message was not shown'")
                onFocusChanged: shallSave();
            }
            SectionHeader { text: qsTr("Device Information"); font.pixelSize: Theme.fontSizeLarge  }
            Separator { color: Theme.primaryColor; horizontalAlignment: Qt.AlignHCenter; width: page.width}
            /*
             * bug info contents may be available later than this page is instantiated.
             * So use a Loader to quiet the "undefined" errors in the log.
             *
             * TODO: I'm sure there is a more QMLy way of doing this but I never quite understood Binding{}
             */
            Loader {
                width: parent.width
                active: (typeof bugInfo.hw !== "undefined") && (typeof bugInfo.os !== "undefined") && (typeof bugInfo.ssu !== "undefined")
                sourceComponent: DeviceInfo{}
            }
            Separator { color: Theme.primaryColor; horizontalAlignment: Qt.AlignHCenter; width: page.width }
            Item { height: Theme.paddingLarge*2; width: parent.width }
            SectionHeader { text: qsTr("Additional Information"); font.pixelSize: Theme.fontSizeLarge }
            Separator { color: Theme.primaryColor; horizontalAlignment: Qt.AlignHCenter; width: page.width}
            TextArea{id: text_add;
                width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                label: qsTr("Add any other information")
                description: qsTr("e.g. links to logs or screenshots.")
                onFocusChanged: shallSave();
            }
            CatSelect { onCategoryChanged: metatags["category"] = category; }
            Slider { id: repro;
                width: parent.width;
                label: qsTr("Reproducibility");
                minimumValue: 0; maximumValue: 100; stepSize: 25 ; value: -1
                onValueChanged: metatags["reproducible"] = value;
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
                property bool hasChanged: false
                automaticCheck: false
                onClicked: {
                    hasChanged = true;
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
                TextArea { id: text_mod_other; enabled: othersw.checked
                    width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                    description: qsTr("e.g. WayDroid and GApps installed")
                    label: qsTr("custom changes, installed packages etc.")
                }
            }
        }
        VerticalScrollDecorator {}
    }
    PullDownMenu { id: pdm
        flickable: flick
        MenuItem { text: qsTr("About"); onClicked: { pageStack.push(Qt.resolvedUrl("AboutPage.qml")) } }
        MenuItem { text: qsTr("Help"); onClicked: { pageStack.push(Qt.resolvedUrl("../components/WelcomeDialog.qml")) } }
        MenuItem { text: qsTr("Reset all to default"); onDelayedClick: { Remorse.popupAction(page, qsTr("Cleared."), function() { resetFields() }) } }
        //MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
    }
    PushUpMenu { id: pum
        flickable: flick
        busy: infoComplete
        MenuLabel { text: qsTr("Bug quality is: %1 ").arg(qualityString) }
        MenuLabel { text: qsTr("Please fill in the required fields") + " " + qsTr("(marked with an asterisk (*))!"); visible: !infoComplete; }
        MenuLabel { text: qsTr("%1 field is incomplete").arg(qsTr("Title"))       ; visible: ( !infoComplete && !titleComplete); }
        MenuLabel { text: qsTr("%1 field is incomplete").arg(qsTr("Description")) ; visible: ( !infoComplete && !descComplete); }
        MenuLabel { text: qsTr("%1 field is incomplete").arg(qsTr("Steps"))       ; visible: ( !infoComplete && !stepsComplete); }
        MenuItem { text: qsTr("Post Bug Report");
            enabled: infoComplete
            onClicked: {
                if (developerMode) {
                    console.debug("Will Post this:\n"
                    + "Title" + getTitle()
                    + "Body:" + getPayload()
                    );
                }
                console.info("Submitting Bug Report... ");
                Qt.openUrlExternally( formToUrl() );
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
            + "OSVERSION: "     + bugInfo.os.version_id + "  \n"
            + "HARDWARE: "      + bugInfo.hw.name + " - " + bugInfo.hw.id + " - " + bugInfo.hw.mer_ha_device + " - " + bugInfo.hw.version_id + " - " + bugInfo.ssu.arch +  "  \n"
            + "UI LANGUAGE: "   + oslanguage + " (user: " + uilocale + ", os: " + oslocale + ")" + "  \n"
            + "REGRESSION: "    + ((regsw.hasChanged) ? ((regsw.checked) ? "yes" : "no") : "not specified")
            + ( (regsw.checked)
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
            + "STEPS TO REPRODUCE:\n"
            + "==============\n\n" + text_steps.text
            + "\n\n"
            + "EXPECTED RESULTS:\n"
            + "============\n\n" + text_expres.text
            + "\n\n"
            + "ACTUAL RESULTS:\n"
            + "===========\n\n" + text_actres.text
            + "\n\n"
            + "MODIFICATIONS:\n"
            + "==========\n\n"
            + " - Patchmanager: " + (pmsw.checked?"yes":"no") + "\n"
            + " - OpenRepos: "    + (orsw.checked?"yes":"no") + "  \n"
            + " - Chum: "         + (chsw.checked?"yes":"no") + "  \n"
            + " - Other: "        + ((othersw.checked)
                ? "yes: " + text_mod_other.text + "  \n"
                : "none specified \n")
            + "\n\n"
            + "ADDITIONAL INFORMATION:\n"
            + "=================\n\n" + text_add.text
            + "\n"
            + "Device Owner User: " + userInfo.username + "  \n"
            + "Home Encryption: " + encStr + "  \n"
            + "\n\n\n\n"
            // add meta tags:
            + metatagsToComment()
            // add footer:
            + "----  \n"
            + "<div align='right'><small><i>" + infoFooter + "</i></small></div>\n"
            + "";
        return payload;
    }
    /* just to be consistent */
    function getTitle() {
        return text_title.text;
    }
    /* encode the payload, return full URL for posting */
    function formToUrl() {
        // handle case for cbeta users:
        var postCategory = (bugInfo.ssu.domain == 'cbeta') ? postCatBeta : postCatBugs;
        return postUrl
            + postCategory
            + "&title=" + encodeURIComponent(getTitle())
            + "&body="  + encodeURIComponent(getPayload());
    }
   /* ****** END POSTING ***** */

   /*
    * ****** AUTOSAVE AND RESTORE *****
    *
    * save input on state changes, and when minimized/closed
    *
    * because some signals might arrive a lot, we use a restarting timer to do
    * the actual saving to prevent bursts.
    */
    signal shallSave()
    property bool preventSave: true // prevent state changes triggering a save, e.g. a form reset
    // listen for minimizing or closing, save more or less immediately then.
    Connections {
        target: app
        onApplicationActiveChanged: {
            if (Qt.application.state == Qt.ApplicationInactive) {
                console.info("App minimized, saving.");
                saveTimer.interval = 200;
                shallSave()
            } else {
                saveTimer.triggeredOnStart = false;
                saveTimer.interval = saveInterval;
            }
        }
        onWillQuit: {
            console.info("App quitting, emergency save!");
            saveTimer.triggeredOnStart = true;
            saveTimer.interval = 200;
            shallSave();
            preventSave = true; // this signal is emitted more than once
        }
    }

    /* timer acts as queue, it's restarted at each signal, and will save after
     * that. This is to prevent write bursts.
     */
    Timer { id: saveTimer
        interval: saveInterval
        running: false
        repeat: false
        onTriggered: {
            saveFields();
            console.debug("timer triggered");
        }
        //onRunningChanged: console.debug("timer %1".arg(running ? "started" : "stopped"));
    }
    // Signal Handler for shallSave
    onShallSave: {
        //console.debug("Signal Handler called");
        if (preventSave) {
            console.debug("Saving currently disabled");
            return;
        }
        // don't overwrite old data with worse data
        if (infoComplete || titleComplete || descComplete || stepsComplete ) {
            saveTimer.restart();
        } else {
            console.debug("Nothing worth saving");
        }
    }
    // save to persistent storage
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
        Util.store(post);
    }
    // clear persistent storage
    function clearSaved() {
        Util.reset();
    }
    // to be called from Pulley Menu
    function resetFields() {
        console.info("Resetting field values");
        restoreFields(defaultFieldContents);
    }

    function restoreSaved() {
        var data = Util.restore();
        if (!!data) {
            //console.debug("restoring:" , data);
            var fields = JSON.parse(data).fields;
            if(page.restoreFields(fields)) {
                app.popup(qsTr("Restored bug report contents from saved state."));
            } else {
                console.warn("Could not restore fields")
            }
        } else {
            console.debug("No valid data received");
        }
    }
    /*
     * set the form fields from an object
     */
    function restoreFields(data) {
        const dataKeys  = Object.keys(data).length;
        if (dataKeys !== fieldKeys) {
            console.assert(( dataKeys == fieldKeys), ("Loaded field value count (%1) differs from known field count (%2), not restoring!").arg(fieldKeys).arg(dataKeys));
            resetFields();
            return false;
        }
        preventSave = true;
        try {
            text_title.text         = data.text_title;
            text_desc.text          = data.text_desc;
            text_steps.text         = data.text_steps;
            text_precons.text       = data.text_precons;
            text_expres.text        = data.text_expres;
            text_actres.text        = data.text_actres;
            text_add.text           = data.text_add;
            text_mod_other.text     = data.text_mod_other;
            regsw.checked           = data.regsw;
            regsw.hasChanged        = data.regsw_haschanged;
            regver.currentIndex     = data.regver;
            regarch.currentIndex    = data.regarch;
            othersw.checked         = data.othersw;
            repro.value             = data.repro;
        } finally {
            preventSave = false;
        }
        return true
    }
   /* ****** END AUTOSAVE AND RESTORE ***** */


}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
