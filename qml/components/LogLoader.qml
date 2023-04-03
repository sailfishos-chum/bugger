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

    property ListModel model: ListModel{}

    onModelChanged: reload()

    function reload() {
        if (!model) return
        for (var i = 0; i < model.count; ++i) {
            getFileFrom(i, model.get(i))
        }
    }

    /* load files from URLs into data buffer */
    function getFileFrom(index, data) {
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
                    console.debug("Filedata loaded: about", r.response.split("\n").length, "lines");
                    model.setProperty(index, "dataStr", r.response)
                } else {
                    console.warn("Filedata load failed:", JSON.stringify(r.response));
                }
            }
        }
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
