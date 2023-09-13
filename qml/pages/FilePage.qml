// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Nemo.FileManager 1.0
import "../components"
import "../config/settings.js" as Settings

Dialog { id: page

    canAccept: false
    property var config: Settings.config

    // NOTE: if you change this, change all the paths in the Systemd units as well!
    readonly property string cacheDir: StandardPaths.documents + "/Bugger/"

    onRejected: filesModel.clear()

    /* Lets the user select a set of files, and copies them into the
     * app-specific Documents location, so that the dirModel can will them up.
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
                    if (i.fileSize == 0) continue;
                    FileEngine.copyFiles(o.filePath)
                    FileEngine.pasteFiles(page.cacheDir)
                }
                acceptedHandled=true
            }
        }
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

    FileModel { id: dirModel;
        path:  page.cacheDir
        active: true
        includeFiles: true
        includeHiddenFiles: false
        includeDirectories: false
        includeParentDirectory: false
        //nameFilters: config.gather.postfixes
        //nameFilters: [ '*.log', '*.txt', '*.json' ]
        onPopulatedChanged: {
            console.info("Detected", dirModel.count, "files.");
            //if (!populated || active) return
            if (!dirModel.populated) return
            //transformer.model = null
            //transformer.active = false
            //filesModel.clear();
            transformer.active = true
            transformer.model = dirModel
       }
    }
    /*
     * Since a FileModel does not have a get() method, and we can't extend its
       elements, popuplate our own model with the extended data.
       Actually we just really need the "pastedUrl" property. This is a FIXME.

       Use an Instantiator to generate the content, as it can use the model directly.
    */
    Instantiator { id: transformer
        active: false
        delegate: ListElement {
            property string title: ""
            property string mimeType: model.mimeType
            property string fileName: model.fileName
            property string filePath: page.cacheDir + model.fileName
            // do not specify an url type here, it will become an object...
            property string url:      Qt.resolvedUrl(filePath)
            property int fileSize:    model.size
            property string pastedUrl: "" // create property so we don't need dynamicRoles
        }
        // after we're done, add ourselves to the model:
        onObjectAdded: function(i,o) { filesModel.set(i,o) }
        onObjectRemoved: function(i,o) { filesModel.remove(i) }
    }

    LogMailer   { id: mailer } // calls jolla-email, Issue #29
    LogShare    { id: sharer } // calls Share by Email, Issue #29
    LogGatherer { id: gather } // executes systemd things
    LogPaster   { id: paster } // uploads files to "pastebin"

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
                text: qsTr("Check the log gathering options")
            }
            ButtonLayout {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                Button { text: qsTr("Configure Logging"); onClicked: pageStack.push("LogConfigPage.qml") }
            }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignJustify
                text: qsTr("Use the <b>%1</b> or <b>%2</b> functions to populate the file list.").arg("Collect Logs").arg("Pick Files") + " "
                    + qsTr("Picked files will be copied to the staging directory, so you can delete them without affecting the original.")
            }
            ButtonLayout {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                Button { text: qsTr("Pick Files"); onClicked: pageStack.push(picker) }
                Button { text: qsTr("Collect Logs"); onClicked: { startGatherer() } }
            }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignJustify
                text: qsTr("Add the log output for a specific Service.") + " "
                      + qsTr("We will try to gather the output from only this unit (<tt>journalctl -u</tt>). Note that this will only work if your user can read the journal at all.");
            }
            ComboBox { id: unitBox
                label: qsTr("Unit")
                value:  (currentIndex === -1) ? qsTr("Please Select") : currentItem.text
                currentIndex: -1
                menu:ContextMenu{
                    Repeater {
                        model: gather.knownUnits.split(',')
                        delegate: MenuItem { text: modelData }
                    }
                }
            }
            /*
            TextField { id: unitField
                width: parent.width
                placeholderText: qsTr("A Unit name (e.g. lipstick)")
                //validator:  RegExValidator { regularExpression: /[0-9a-f._-]+/ }
                inputMethodHints: Qt.ImhUrlCharactersOnly
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: focus = false
            }
            */
            ButtonLayout {
                width: parent.width
                Button {
                    text: qsTr("Collect Unit Log")
                    //enabled: ( (unitField.text.length > 3) && unitField.acceptableInput )
                    enabled: (unitBox.currentIndex > -1 )
                    onClicked: {
                        const template = config.gather.perunit_template;
                        //const myunit = template + "@" + unitField.text + ".service";
                        //const myunit = template + "@" + unitBox.currentItem.text.replace(".service","") + ".service";
                        const myunit = template + "@" + unitBox.currentItem.text + ".service";
                        gather.collectLog(myunit);
                    }
                }
            }

            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignJustify
                text: qsTr("Long press on a file in the list to view or remove it.") + " "
                    + qsTr("Finally, upload the data to add the links to your Bug Report.")
            }
            ButtonLayout {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                Button { text: qsTr("Upload Contents"); enabled: filesModel.count > 0;  onClicked: { upload() } }
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
            //MenuItem { text: qsTr("Pick Files"); onClicked: pageStack.push(picker) }
            //MenuItem { text: qsTr("Configure Logging"); onClicked: pageStack.push("LogConfigPage.qml") }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
