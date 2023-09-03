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
import Nemo.FileManager 1.0
import "../components"
import "../config/settings.js" as Settings

Dialog { id: page

    canAccept: false
    property var config: Settings.config

    onRejected: filesModel.clear()

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
                    var o = selectedContent.get(i)
                    o["dataStr"]    = ""; // prepare property so we don't need dynamicRoles
                    o["pastedUrl"]  = ""; // prepare property so we don't need dynamicRoles
                    filesModel.append(o)
                    console.debug("added", i+1, "of" , selectedContent.count,  "files:")
                    console.debug(JSON.stringify(o, null, 2))
                }
                acceptedHandled=true
            }
        }
    }

    function loadFiles() {
        loader.model = filesModel
        loader.reload()
    }
    function upload() {
        paster.model = filesModel
        paster.upload()
    }
    function startGatherer()   { gather.start() }
    function emailshare()   {
        //sharer.share()
        const body = "This is a Test."
        const content = encodeURI("mailto:" + config.email.to
            + "?subject=" + config.email.subject + " " + Math.random()
            + "&body=" + body
            )
        var res = [
            //{ "data": content }
            body,
        ];
        console.debug("Sharing: ", filesModel.count, " elements")
        for (var i = 0; i < filesModel.count; ++i) {
            const f = filesModel.get(i)
            if (f.dataStr.length > 0) {
                console.debug("Sharing: adding data")
                res.push({ "data": f.dataStr, "linkTitle": f.title,  "name": f.fileName })
            } else if (f.filePath.length > 0) {
                res.push( f.filePath )
                console.debug("Sharing: adding path")
            } else {
                console.warn("Sharing: trying to add element with no content")
            }
        }
        sharer.resources = res;
        console.debug("Sharing: ", res)
        sharer.trigger();
    }
    function email() {
        console.time("Constructed Email in")
        const body = ''
        //const crlf = '\r\n'
        //const mboundary = 'mixed_boundary' + Math.random().toString(14).substr(2, 12)
        //const rboundary = 'related_boundary' + Math.random().toString(14).substr(2, 12)
        //body += 'Content-Type: multipart/mixed; boundary="' + mboundary + '"' + crlf
        //body += '--'+ mboundary + crlf
        //body += 'Content-Type: text/plain' + crlf
        //body += 'Content-Transfer-Encoding: 8bit' + crlf + crlf
        //body += 'This email was created using ' + Qt.application.name + ' ' + Qt.application.version + '.\n\n'
        //body += 'There should be ' + filesModel.count + ' files attached.\n\n'
        //body += crlf + crlf
        //body += '--'+ mboundary + crlf
        //body += 'Content-Type: multipart/related; boundary="' + rboundary + '"' + crlf
        //for (var i = 0; i < filesModel.count; ++i) {
        //    const f = filesModel.get(i)
        //    if (f.dataStr.length > 0) {
        //        body += '--'+ rboundary + crlf
        //        body += 'Content-Type: text/plain; name="' + f.fileName + '"' + crlf
        //        body += 'Content-ID: ' +  f.fileName + crlf
        //        body += 'Content-Transfer-Encoding: base64' + crlf + crlf
        //        body += Qt.btoa(f.dataStr)  + crlf + crlf
        //    }
        //}
        //// final boundaries
        //body += crlf + crlf + '--'+ rboundary + '--' + crlf
        //body += crlf + crlf + '--'+ mboundary + '--' + crlf
        body += 'This email was created using ' + Qt.application.name + ' ' + Qt.application.version + '.\n\n'
        body += 'There should be ' + filesModel.count + ' files attached.\n\n'
        for (var i = 0; i < filesModel.count; ++i) {
            const f = filesModel.get(i)
            if (f.dataStr.length > 0) {
                body += 'begin-base64 644 ' + f.fileName + '\n'
                //body += Qt.btoa(f.dataStr) + '\n'
                body += Qt.btoa(encodeURIComponent(f.dataStr).replace(/%([0-9A-F]{2})/g, function toSolidBytes(match, p1) { return String.fromCharCode('0x' + p1) }))
                body += '\n====' + '\n'
            }
        }
        console.timeEnd("Constructed Email in")
        mailer.newMail(
            config.email.subject + " "+ Math.random(),
            config.email.to,
            '',
            '',
            body
        )
    }

    FileWatcher { id: watcher }
    LogMailer   { id: mailer } // calls jolla-email, Issue #29
    LogShare    { id: sharer } // calls Share by Email, Issue #29
    LogGatherer { id: gather } // executes systemd things
    LogLoader   { id: loader } // gets file contents
    LogPaster   { id: paster } // uploads files to "pastebin"
    /*
     * after the Gathere signals that it is finished, add file information to the model
      */
    Connections {
        target: gather
        /*
         * mimic the selectedContentProperties schema from FilePicker and add to the model
         *
         * {
             "contentType": 6,
             "fileName": "2022-12-01_harbour-bugger-gather-hybris-logs.log",
             "filePath": "/home/nemo/Documents/2022-12-01_harbour-bugger-gather-hybris-logs.log",
             "fileSize": 439122,
             "mimeType": "text/x-log",
             "title": "2022-12-01_harbour-bugger-gather-hybris-logs.log",
             "url": "file:///home/nemo/Documents/2022-12-01_harbour-bugger-gather-hybris-logs.log",
             "url": "file:///home/nemo/Documents/2022-12-01_harbour-bugger-gather-hybris-logs.log"
           }
         */
        onLogCreatedChanged: {
            const logBaseName = new Date().toISOString().substring(0,10) + "_" + config.gather.basename
            const elements = []
            const o = {}
            const postfixes = config.gather.postfixes
            const pretty    = config.gather.prettynames
            postfixes.forEach(function(postfix) {
                o = {};
                o["title"] = "";
                const fn = logBaseName + postfix;
                for ( var i = 0; i < pretty.length; ++i) {
                    const re = new RegExp(pretty[i].pattern);
                    if (re.test(postfix)) {
                        console.debug("found pretty name", pretty[i].name, "from pattern", pretty[i].pattern, "for filename", fn)
                        o["title"] = pretty[i].name;
                        break;
                    }
                };
                o["mimeType"]   = (/json$/.test(postfix)) ? "application/json" : "text/plain";
                o["fileName"]   = logBaseName + postfix;
                o["filePath"]   = StandardPaths.documents + "/Bugger/" + o["fileName"];
                o["url"]        = Qt.resolvedUrl(o["filePath"]);
                o["fileSize"]   = -1; // prepare property so we don't need dynamicRoles
                o["dataStr"]    = ""; // prepare property so we don't need dynamicRoles
                o["pastedUrl"]  = ""; // prepare property so we don't need dynamicRoles
                console.debug("Adding:", JSON.stringify(o,null,2))
                elements.push(o)
            })
            // add the generated information to the model
            elements.forEach(function(element) {
                if (watcher.testFileExists(element.filePath)) {
                    filesModel.append(element)
                } else {
                    console.warn("File not found.");
                }
            })
            // ... and trigger loading file contents:
            if (filesModel.count > 0) loadFiles()
        }
    }

    Connections {
        target: paster
        // after paster is done, allow finishing the dialog
        onDoneChanged: {
            if (!paster.done) return
            canAccept = true
            progress.visible = false
            app.popup(qsTr("Uploading finished: %1 successful, %2 error.").arg(paster.successCount).arg(paster.errorCount))
        }
        // show progress of uploads:
        onUploadingChanged: {
            if (paster.uploading !== "") {
                console.debug("uploading", paster.uploading)
                progress.visible = true
                progress.label = qsTr("uploading %1 files, %2 done").arg(filesModel.count).arg(paster.successCount)
            }
        }
    }

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height + header.height
        DialogHeader { id: header ; width: parent.width ; title: qsTr("Gather Files") }
        Column { id: col
            width: parent.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            spacing: Theme.paddingMedium
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignJustify
                text: qsTr("Here you can gather and add log files, which will be uploaded to a 'Pastebin' type of service, and added as links to your Bug Report.") + " "
                    + "\n\n"
                    + qsTr("The data will be uploaded to %1, and be publicly available. Be sure you don't add private or confidential information.").arg(config.paste.host)
            }
            SectionHeader { text: qsTr("Workflow") }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignJustify
                text: qsTr("Use the <b>%1</b> or <b>%2</b> functions to populate the file list.").arg("Collect Logs").arg("Pick Files") + " "
                    + qsTr("Long press on a file in the list to view or remove it.") + " "
                    + qsTr("Finally, upload the data to add the links to your Bug Report.")
            }
            Flow {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                Button { text: qsTr("Collect Logs"); onClicked: { startGatherer() } }
                Button{ enabled: false; text: "->"; width: Theme.iconSizeSmall }
                Button { text: qsTr("Upload Contents"); enabled: filesModel.count > 0;  onClicked: { upload() } }
                Button{ enabled: false; text: "->"; width: Theme.iconSizeSmall }
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
            MenuItem { text: qsTr("Share via E-Mail"); enabled: filesModel.count > 0; onClicked: { emailshare() } }
            MenuItem { text: qsTr("Send E-Mail"); enabled: filesModel.count > 0;      onClicked: { email() } }
            MenuItem { text: qsTr("Help on Collecting Logs"); onClicked: { pageStack.push(Qt.resolvedUrl("help/LogHelp.qml")) } }
            MenuItem { text: qsTr("Pick Files"); onClicked: pageStack.push(picker) }
            MenuItem { text: qsTr("Configure Logging"); onClicked: pageStack.push("JournalPage.qml") }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
