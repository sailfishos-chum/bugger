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

QtObject {
    id: page
    property var config: Settings.config.paste
    property string postUrl: config.scheme + "://" +  config.host + config.uri

    function pasteFile() {

        var r = new XMLHttpRequest()
        r.open('POST', postUrl);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        r.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        //console.debug("Sending:", payload);
        const payload = Qt.encodeURIComponent(fileContent);
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
