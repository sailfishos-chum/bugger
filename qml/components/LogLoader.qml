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

QtObject {
    id: page

    property ListModel model
    property ListModel outModel: ListModel{}

    property bool done: model.count == outModel.count
    onDoneChanged: console.debug("done", done, outModel.count)

    onModelChanged: {
        if (!model) return
        for (var i = 0; i < model.count; ++i) {
            getFileFrom(model.get(i))
        }
    }


    /* load files from URLs into data buffer */
    function getFileFrom(data) {
        //console.debug("Trying to load file contents for", JSON.stringify(data))
        var url = data.url
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
                    //console.debug("Filedata loaded: about", r.response.split("\n").length, "lines");
                    const o = {
                        "title"   : data["title"],
                        "mimeType": data["mimeType"],
                        "fileName": data["fileName"],
                        "filePath": data["filePath"],
                        "url"     : data["url"],
                        "dataStr" : r.response
                    }
                    //console.debug("datastr:", o["dataStr"])
                    //console.debug("adding to outmodel:", JSON.stringify(o))
                    outModel.append(o);
                } else {
                    console.debug("Filedata load failed:", JSON.stringify(r.response));
                }
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
