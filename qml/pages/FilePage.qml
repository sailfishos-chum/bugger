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
import Sailfish.Pickers 1.0
import "../components"
import "../config/settings.js" as Settings

Dialog { id: page

    canAccept: false
    property var config: Settings.config
    property var links: []

    /*
    states: [
        State { name: "populated"; when: filesModel.count > 0
        },
        State { name: "prepared";
        },
        State { name: "uploading"; when: (loadedFiles.count > 0) && (!paster.done)
            PropertyChanges { target: busy; running: true }
        },
        State { name: "uploaded"; when: paster.done
            PropertyChanges { target: busy; running: false }
        }
    ]
    onStateChanged: console.debug("New state:", state)
    */

    Component { id: picker
        MultiFilePickerDialog  {
            title: qsTr("Select log files to add")
            nameFilters: [ '*.log', '*.txt', '*.json' ]
            // signal is received twice
            property bool acceptedHandled: false
            onAccepted: {
                if (acceptedHandled) return
                for (var i = 0; i < selectedContent.count; ++i) {
                    filesModel.append(selectedContent.get(i))
                }
                loadFiles()
                acceptedHandled=true
            }
        }
    }

    function loadFiles() {
        loader.model = filesModel
    }
    function upload() {
        paster.model = filesModel
    }
    function startGatherer()   { gather.start() }
    LogGatherer { id: gather } // executes systemd things
    LogLoader   { id: loader } // gets file contents
    LogPaster   { id: paster } // uploads files to "pastebin"
    Connections {
        target: gather
        onLogCreatedChanged: {
            // mimic the selectedContentProperties of the Picker and add to the model
            const logBaseName = new Date().toISOString().substring(0,10) + "_" + "harbour-bugger-gather-logs"
            const d = []
            const o = {}
            //const postfixes = [ ".log", ".json", "_kernel.log", "_kernel.json" ];
            const postfixes = [ ".log", "_kernel.log" ];
            postfixes.forEach(function(postfix) {
                o = {};
                o["title"] = (
                    ( (/_kernel/.test(postfix)) ? "Kernel" : "Journal" )
                    + " "
                    + ((/json/.test(postfix)) ? "(JSON)" : "" )
                );
                o["mimeType"]   = (/json$/.test(postfix)) ? "application/json" : "text/plain";
                o["fileName"]   = logBaseName + postfix;
                o["filePath"]   = StandardPaths.documents + "/" + o["fileName"];
                o["url"]        = Qt.resolvedUrl(o["filePath"]);
                o["dataStr"]    = ""; // prepare property so we don't need dynamicRoles
                o["pastedUrl"]  = ""; // prepare property so we don't need dynamicRoles
                //console.debug("Adding:", JSON.stringify(o,null,2))
                d.push(o)
            })
            // add the generated information to the model
            d.forEach(function(element) { filesModel.append(element)})
            loadFiles()
        }
    }
    Connections {
        target: paster
        onDoneChanged: {
            if (!paster.done) return
            for (var i = 0; i < filesModel.count; ++i) {
                var d = filesModel.get(i)
                //links.push('<a href="' + d.pastedUrl + '">' + d.fileName + '</a>')
                if (d.title && d.pastedUrl) {
                    links.push(' - [' + d.title + '](' + d.pastedUrl + ')  ')
                } else if (d.fileName && d.pastedUrl) {
                    links.push(' - [' + d.fileName + '](' + d.pastedUrl + ')  ')
                }
            }
            canAccept = true
            progress.visible = false
            app.popup(qsTr("Uploading finished: %1 successful, %2 error.").arg(paster.successCount).arg(paster.errorCount))
        }
        onUploadingChanged: {
            if (paster.uploading !== "") {
                console.debug("uploading", paster.uploading)
                progress.visible = true
                progress.label = qsTr("uploading %1/%2").arg(paster.successCount + 1).arg(filesModel.count)
            }
        }
    }

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        DialogHeader { id: header ;
            width: parent.width
            cancelText: qsTr("Back")
            acceptText: qsTr("Apply")
            title: qsTr("Gather Files")
        }
        Column { id: col
            width: parent.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignJustify
                text: qsTr("Here you can gather and add log files, which will be uploaded to a 'Pastebin' type of service, and added as links to your Bug Report.") + " "
                    + "\n\n"
                    + qsTr("Use the Pulley Menu to populate the file list.") + " "
                    + qsTr("Long press on a file in the list to remove.") + " "
                    + qsTr("Finally, use the Pulley Menu to upload the data and add the links.")
                    + "\n\n"
                    + qsTr("The data will be uploaded to %1, and be publicly available. Be sure you don't add private or confidential information.").arg(config.paste.host)
            }
            ProgressBar { id: progress
                indeterminate: true
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
            }
            SectionHeader { text: qsTr("List of files to upload") }
            FileList { id: fileList; model: filesModel
                cellWidth: page.isLandscape ? parent.width/2 : parent.width
            }
        }
        VerticalScrollDecorator {}
        PullDownMenu { id: pdm
            flickable: flick
            MenuItem { text: qsTr("Upload Contents"); onClicked: { upload() } }
            MenuItem { text: qsTr("Add Files"); onClicked: pageStack.push(picker) }
            MenuItem { text: qsTr("Collect Logs"); onClicked: { startGatherer() } }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
