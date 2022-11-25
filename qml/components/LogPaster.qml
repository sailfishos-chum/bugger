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

    property ListModel model
    property ListModel outModel: ListModel{}
    property bool done: model.count == outModel.count

    onModelChanged: {
        if (!model) return
        for (var i = 0; i < model.count; ++i) {
            pasteFile(model.get(i))
            //delay(pasteFile(model.get(i)))
        }
    }

    Timer { id: delayTimer; interval: 1000 }
    function delay(callback) {
        delayTimer.triggered.connect(callback)
        delayTimer.start();
    }

    function pasteFile(data) {
        //console.debug("trying to upload:", JSON.stringify(data))
        var r = new XMLHttpRequest()
        r.open('POST', postUrl);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        r.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        //console.debug("Sending:", payload);
        const fileContent = data["dataStr"]

        const payload = 
            'expiry_days=' + config.expireDays
            + '&title='    + data.fileName
            + '&content='  + encodeURIComponent(fileContent)
        //console.debug("sending:", payload);
        r.send(payload);

        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200 || r.status == 0) {
                    console.debug("upload sucessful:", r.response);
                    const o = {
                        "title"     : data["title"],
                        "mimeType"  : data["mimeType"],
                        "fileName"  : data["fileName"],
                        "filePath"  : data["filePath"],
                        "url"       : data["url"],
                        "dataStr"   : data["dataStr"],
                        "pastedUrl" : r.response
                    }
                    outModel.append(o);
                } else {
                    console.debug("error in processing request.", r.status, r.statusText);
                }
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
