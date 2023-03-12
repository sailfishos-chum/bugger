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

    onModelChanged: {
        if (!model) return
        successCount = 0;
        errorCount = 0;
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
