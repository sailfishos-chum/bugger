// Copyright (c) 2022,2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.6
import "../config/settings.js" as Settings

Item {
    property var config: Settings.config.paste
    property string postUrl: config.scheme + "://" +  config.host + config.uri
    property string uploading: ""

    property ListModel model: ListModel{}
    property bool done: model.count == (successCount + errorCount)
    property int successCount: 0
    property int errorCount: 0

    WorkerScript { id: worker
        source: "../js/logworker.js"
        onMessage: function(m) {
            if (m.event === "readError") {
                errorCount++
                app.popup(qsTr("Error uploading %1: %2 - %3", "%1: file name, %2 error code, %3: error message").arg(m.file).arg(m.code).arg(m.text));
            }
            if (m.event === "pasteOk") { successCount++ }
            if (m.event === "pasteError") {
                errorCount++
                app.popup(qsTr("Error uploading %1: %2 - %3", "%1: file name, %2 error code, %3: error message").arg(m.file).arg(m.code).arg(m.text));
            }
            if (m.event === "uploading") { uploading = m.file }
        }
    }

    function upload() {
        if (!model) return
        worker.sendMessage({ action: "loadAndPaste", model: model, url: postUrl, expire: config.expireDays })
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
