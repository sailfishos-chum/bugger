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

    /*
    states: [
        State { name: "populated"; when: selectedFiles.count > 0
        },
        State { name: "prepared";
        },
        State { name: "uploading"; when: (loadedFiles.count > 0) && (!paster.done)
            PropertyChanges { target: busy; running: true }
        },
        State { name: "uploaded"; when: paster.done
            PropertyChanges { target: page; uploadedFiles: paster.outModel; canAccept: true }
            PropertyChanges { target: busy; running: false }
        }
    ]
    onStateChanged: console.debug("New state:", state)
    */

    Component { id: picker
        MultiFilePickerDialog  {
            title: qsTr("Select log files  to add")
            nameFilters: [ '*.log', '*.txt', '*.json' ]
            // signal is received twice
            property bool acceptedHandled: false
            onAccepted: {
                if (acceptedHandled) return
                for (var i = 0; i < selectedContent.count; ++i) {
                    selectedFiles.append(selectedContent.get(i))
                }
                loadFiles()
                acceptedHandled=true
            }
        }
    }

    property ListModel selectedFiles: ListModel{}
    property ListModel loadedFiles:   ListModel{}
    property ListModel uploadedFiles: ListModel{}

    function loadFiles() {
        for (var i = 0; i < selectedFiles.count; ++i) {
            if (!selectedFiles.get(i).dataStr) {
                loader.getFileFrom(selectedFiles.get(i))
            }
        }
    }
    function upload() {
        paster.model = loader.outModel
    }
    function startService()   { gather.startService() }
    LogGatherer { id: gather }
    LogLoader   { id: loader }
    LogPaster   { id: paster }
    Connections {
        target: gather
        onLogCreatedChanged: {
            // mimic the selectedContentProperties of the Picker and add to the model
            const logBaseName = new Date().toISOString().substring(0,10) + "_" + "harbour-bugger-gather-logs"
            const d = []
            const o = {}
            const postfixes = [ ".log", ".json", "_kernel.log", "_kernel.json" ];
            postfixes.forEach(function(postfix) {
                o = {};
                o["title"] = (
                    ( (/_kernel/.test(postfix)) ? "Kernel" : "Journal" )
                    + " "
                    + ((/json/.test(postfix)) ? "(JSON)" : "" )
                );
                o["mimeType"] = (/json$/.test(postfix)) ? "application/json" : "text/plain";
                o["fileName"] = logBaseName + postfix;
                o["filePath"] = StandardPaths.documents + "/" + o["fileName"];
                o["url"]      = Qt.resolvedUrl(o["filePath"]);
                //console.debug("Adding:", JSON.stringify(o,null,2))
                d.push(o)
            })
            // add the generated information to the model
            d.forEach(function(element) { selectedFiles.append(element)})
            loadFiles()
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
                color: Theme.highlightColor
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
            SectionHeader { text: qsTr("List of files to upload") }
            FileList { id: fileList; model: selectedFiles
                 cellWidth: page.isLandscape ? parent.width/2 : parent.width
            }
        }
        VerticalScrollDecorator {}
        PageBusyIndicator {id: busy}
        PullDownMenu { id: pdm
            flickable: flick
            MenuItem { text: qsTr("Upload Contents"); onClicked: upload() }
            MenuItem { text: qsTr("Pick additional Files"); onClicked: pageStack.push(picker) }
            MenuItem { text: qsTr("Collect Journal"); onClicked: { startService() } }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
