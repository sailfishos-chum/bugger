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
// import "../components"
import "../config/settings.js" as Settings
// import "../js/util.js" as Util

Page {
    id: page

    /* post submit settings */
    property var config: Settings.config

    readonly property string postScheme:    config.upload.scheme
    readonly property string postHost:      config.upload.host
    readonly property string postUri:       config.upload.uri
    readonly property url    postUrl:       postScheme + '://' + postHost + postUri

    property ListModel selectedFiles: ListModel{}
    property var fileData: []

    states: [
        State { name: "selected"; when: selectedFiles.count > 0
        },
        State { name: "prepared"; when: (fileData.length == selectedFiles.count)
            PropertyChanges { target: uploadbutton; enabled: true }
        },
        State { name: "uploading";
        },
        State { name: "uploaded";
        }
    ]

    /*
    Component { id: picker
        MultiContentPickerDialog  {
            title: qsTr("Select log files or screenshots")
            onAccepted: {
                for (var i = 0; i < selectedContent.count; ++i) {
                    getFileFrom(i, selectedContent.get(i).url)
                    selectedFiles.append(selectedContent.get(i))
                }
            }
        }
    }
    */
    Component { id: picker
        MultiDocumentPickerDialog  {
            onAccepted: {
                for (var i = 0; i < selectedContent.count; ++i) {
                    getFileFrom(i, selectedContent.get(i).url)
                    selectedFiles.append(selectedContent.get(i))
                }
            }
        }
    }

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: col.height
        Column { id: col
            width: parent.width
            PageHeader { id: header ; title: qsTr("Upload Files") }
            SectionHeader { text: qsTr("List of files to upload") }
            GridView {
                width: parent.width
                height: Theme.iconSizeMedium * Math.max(count, 2)
                model: selectedFiles
                cellWidth: parent.width/2
                cellHeight: Theme.iconSizeMedium
                delegate: ListItem {
                    anchors.margins: Theme.paddingSmall
                    width: GridView.view.cellWidth
                    contentHeight: Math.max(GridView.view.cellHeight, Theme.iconSizeMedium, content.height)
                    Row { id: content
                        height: icon.height
                        width: parent.width
                        Icon { id: icon
                            source: Theme.iconForMimeType(mimeType)
                            height: Theme.iconSizeMedium
                            width: height
                            sourceSize.width: height
                            sourceSize.height: height
                        }
                        Column {
                            width: parent.width - icon.width
                            anchors.verticalCenter: icon.verticalCenter
                            Label { text: fileName; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeSmall; color: Theme.highlightColor }
                            Label { text: mimeType; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
                            //Label { text: filePath; width: parent.width; truncationMode: TruncationMode.Fade; font.pixelSize: Theme.fontSizeTiny; color: Theme.secondaryColor }
                        }
                    }
                    menu: ContextMenu {
                        width: (parent) ? parent.width : 0 // gives a log warning but works ;)
                        MenuItem { text: qsTr("Remove"); onClicked: { content.hidden = true; selectedFiles.remove(index,1) } }
                    }
                }
            }
            ValueButton {
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Select Files")
                value: qsTr("Selected: %1").arg(( selectedFiles ? selectedFiles.count : qsTr("None")))
                onClicked: pageStack.push(picker)
            }
            ButtonLayout {
                Button {
                    enabled: ( selectedFiles && (selectedFiles.count > 0) && ( page.state != "prepared" ) )
                    text: "Prepare for upload"
                    onClicked: {
                        fileData = [];
                        for (var i = 0; i < selectedFiles.count; ++i) {
                            getFileFrom(i, selectedFiles.get(i).url)
                        }
                    }
                }
                Button { id: uploadbutton
                    enabled: false
                    text: "Upload"
                    onClicked: {
                        uploadFiles()
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }

   /*
    * ****** POSTING *****
    *
    * attach files to bug report post
    *
    * */

    /* load files from URLs into data buffer */
    function getFileFrom(i, url) {
        var r = new XMLHttpRequest()
        r.open('GET', url);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        //r.responseType = 'text';
        //r.responseType = 'arraybuffer'; //we need binary data
        //r.responseType = 'blob'; //we need binary data
        r.send();

        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200 || r.status == 0) {
                    // FIXME: This is stupid and racy as hell, but direct setting does not work...
                    var d = page.fileData
                    d[i] = r.response;
                    page.fileData = d;
                    console.debug("Filedata loaded:", i, page.fileData.length);
                } else {
                    console.debug("Filedata load failed:", JSON.stringify(r.response));
                }
            }
        }
    }

    function uploadFiles() {

        var r = new XMLHttpRequest()
        r.open('POST', postUrl);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
       // construct payload:
        const boundary = '------------' + Math.random().toString(14).substr(2, 12)
        r.setRequestHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);

        var payload = '--' + boundary + '\n'
            + 'Content-Disposition: form-data; name="upload_type"\n\n'
            + 'composer' + '\n'
            + '--' + boundary + '\n'
            + 'Content-Disposition: form-data; name="synchronous"\n\n'
            + "true" + '\n'

        for (var i = 0; i < selectedFiles.count; ++i) {
            console.debug("Adding: ", selectedFiles.get(i).fileName)

            payload +=
                '--' + boundary + '\n'
                + 'Content-Disposition: form-data; name="name"\n\n'
                + selectedFiles.get(i).fileName + '\n'
                + '--' + boundary + '\n'
                +'Content-Disposition: form-data; name="file"; filename="' + selectedFiles.get(i).fileName + '";\n'
                +'Content-Type: ' +  selectedFiles.get(i).mimeType + '\n\n'
                +  page.fileData[i] + '\n';
        }
        payload += '--' + boundary + '--'

        //console.debug("Sending:", payload);
        r.send(payload);

        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200 || r.status == 0) {
                    var rdata = JSON.parse(r.response);
                    console.debug("upload sucessful.");
                    console.debug("url:", rdata.url);
                    console.debug("fname:", rdata.original_filename);
                    console.debug("surl:", rdata.short_url);
                    console.debug("spath:", rdata.short_path);
                } else {
                    console.debug("error in processing request.", r.status, r.statusText);
                }
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
