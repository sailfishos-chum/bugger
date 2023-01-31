/*

Apache License 2.0

Copyright (c) 2023 Peter G. (nephros)

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
    readonly property string infoFooter: 'the initial version of this feature request was created using '
        + '<a href="' + 'https://github.com/sailfishos-chum/bugger/releases/">'
        + Qt.application.name + ' ' + Qt.application.version
        + '</a>'

    property var links: []

    // used to clear this form, and the persistent storage
    property var defaultFieldContents: {
        "text_title":       "",
        "text_desc":        "",
        "links":            []
    }

    // Pavlov!! :)
    NonGraphicalFeedback { id: postiveFeedback; event: "positive_confirmation" }
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
        if ( state === "good" || state === "full" ) {
            postiveFeedback.play()
            app.popup(qsTr("Achievement unlocked! The quality of your bug report is %1!").arg(page.qualityString));
        }
    }

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        Column { id: col
            width: parent.width
            PageHeader { id: header ; title: qsTr("Feature Request (%1)").arg(qualityString) }
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
            }

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
            Separator { color: Theme.primaryColor; horizontalAlignment: Qt.AlignHCenter; width: page.width}
            SectionHeader { text: qsTr("Additional Information") }
            TextArea{id: text_add;
                width: parent.width; height: Math.max(implicitHeight, Theme.itemSizeLarge);
                label: qsTr("Add any other information")
                description: qsTr("e.g. links to logs or screenshots.")
                onFocusChanged: shallSave();
            }
            /*
            Column {
                width: parent.width
                SectionHeader { text: qsTr("Links/Attachments (%1)").arg(fileList.count) }
                FileList{ id: fileList
                    model: filesModel
                    showPlaceholder: false
                }
            }
            */
        }
        VerticalScrollDecorator {}
    }
    PullDownMenu { id: pdm
        flickable: flick
        MenuItem { text: qsTr("About"); onClicked: { pageStack.push(Qt.resolvedUrl("AboutPage.qml")) } }
        MenuItem { text: qsTr("Help"); onClicked: { pageStack.push(Qt.resolvedUrl("../components/WelcomeDialog.qml")) } }
        MenuItem { text: qsTr("Add Logfiles")
            onClicked: {
                var dialog = pageStack.push(Qt.resolvedUrl("FilePage.qml"))
                dialog.accepted.connect(function() {
                    console.debug("dialog done.")
                    page.links = dialog.links
                })
            }
        }
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
        MenuItem { text: qsTr("Post Feature Request");
            enabled: infoComplete
            onClicked: {
                if (developerMode) {
                    console.debug("Will Post this:\n"
                    + "Title" + getTitle()
                    + "Body:" + getPayload()
                    );
                }
                console.info("Submitting Feature Request... ");
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
            + "ADDITIONAL INFORMATION:\n"
            + "=================\n\n" + text_add.text
            + "\n"
            + "ATTACHMENTS:\n"
            + "=================\n\n"
            + links.join('\n')
            + "\n\n\n\n"
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
        var postCategory = (bugInfo.ssu.domain == 'cbeta') ? postCatBeta : postCatFeatures;
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
            "text_add":         text_add.text,
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
        } finally {
            preventSave = false;
        }
        return true
    }
   /* ****** END AUTOSAVE AND RESTORE ***** */


}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
