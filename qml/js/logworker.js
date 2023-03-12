/*
Copyright (c) 2023 Peter G. (nephros)
*/
// SPDX-License-Identifier: Apache-2.0

.pragma library

WorkerScript.onMessage(m) {
    if (m.action === "getFile") { getFile ( m.parms.model, m.parms.index ) }
}
/* load files from URLs into data buffer */
    function getFile(model, index) {
        var data = model.get(index)
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
                    if (r.response.length > 0) {
                        model.setProperty(index, "dataStr", r.response)
                        model.sync()
                    } else {
                        console.warn("File was empty, not added:", JSON.stringify(r.response));
                    }
                } else {
                    console.warn("Filedata load failed:", JSON.stringify(r.response));
                }
            }
        }
    }

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
