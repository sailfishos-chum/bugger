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
            if (m.event === "pasteOk") { successCount++ }
            if (m.event === "pasteError") {
                errorCount++
                app.popup(qsTr("Error uploading: %1 - %2", "%1: error code, %2: error message").arg(m.code).arg(m.text));
            }
            if (m.event === "uploading") { uploading = m.file }
        }
    }

    function upload() {
        if (!model) return
        for (var i = 0; i < model.count; ++i) {
            worker.sendMessage({ action: "pasteFile", model: model, index: i, url: postUrl, expire: config.expireDays })
            //delay(pasteFile(model.get(i)))
        }
    }

    Timer { id: delayTimer; interval: 1000 }
    function delay(callback) {
        delayTimer.triggered.connect(callback)
        delayTimer.start();
    }

}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
