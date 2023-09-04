// Copyright (c) 2022, 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    property string fileName
    property string fileData: ""
    property bool busy: false
    property bool truncated: false
    readonly property int maxlen: Math.floor(0.5 * 1024 * 1024)

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (fileName && fileData.length === 0) { xhr.load(fileName) } else { console.warn("Filename is empty") }
        } else if (status == PageStatus.Deactivating) {
            delete fileData
            delete xhr
        }
    }
    QtObject { id: xhr
        signal loaded()
        property int result

        function load(path) {
            busy = true;

            var query = Qt.resolvedUrl(path);
            var r = new XMLHttpRequest();
            r.open('GET', query);
            r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

            r.send();
            r.onreadystatechange = function(event) {
                if (r.readyState == XMLHttpRequest.DONE) {
                    if (r.status === 200) {
                        const len = r.response.length
                        // limit size, i.e. memory usage:
                        if (len > maxlen) {
                            page.fileData = r.response.substring(len - maxlen, maxlen );
                            page.truncated = true;
                        } else {
                            page.fileData = r.response;
                        }
                        xhr.result  = r.status
                        loaded()
                    } else {
                        xhr.result  = r.status
                        console.debug("error in processing request.", query, r.status, r.statusText);
                    }
                    busy = false;
                } else if (r.readyState == XMLHttpRequest.LOADING) {
                    if (r.response.length > maxlen) {
                        page.fileData = r.response.substring(len - maxlen, maxlen );
                        console.warn("Response getting too large, aborting.")
                        page.truncated = true;
                        r.abort()
                        loaded()
                    }
                }
            }
        }
    }

    PageHeader { id: header
        title: qsTr("Log File") + (page.truncated ? qsTr(" truncated") : "")
        description: fileName.substring(fileName.lastIndexOf("/")+1, fileName.length)
        Separator { anchors.verticalCenter: parent.bottom; width: parent.width; color: Theme.primaryColor }
    }

    SilicaFlickable { id: flick
        clip: true
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.height - header.height
        contentHeight: content.height
        contentWidth: content.width
        bottomMargin: Theme.paddingLarge
        leftMargin: Theme.horizontalPageMargin
        rightMargin: Theme.horizontalPageMargin
        ScrollDecorator{}
        Label { id: content
            //x: Theme.horizontalPageMargin

            text: page.fileData.length > 0 ? page.fileData : ""

            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            font.family: "monospace"
            wrapMode: Text.NoWrap
            verticalAlignment: Text.AlignVCenter
        }
    }
    PageBusyIndicator{ running: page.busy}
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
