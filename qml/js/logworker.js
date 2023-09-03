// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

.pragma library

WorkerScript.onMessage = function(m) {
    if (m.action === "reload") reload(m.model)
    if (m.action === "pasteFile") pasteFile(m.model, m.index, m.url, m.expire)

    function reload(model) {
        if (!model) return
        for (var i = 0; i < model.count; ++i) {
            getFile(model, i)
        }
    }


    /* load files from URLs into data buffer */
    function getFile(model, index) {
        var data = model.get(index)
        var url = data.url
        var r = new XMLHttpRequest()
        r.open('GET', url);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        r.send();

        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200 || r.status == 0) {
                    console.debug("Filedata loaded: about", r.response.split("\n").length, "lines");
                    if (r.response.length > 0) {
                        model.setProperty(index, "dataStr", r.response)
                        // FIXME: use response header for this?
                        model.setProperty(index, "fileSize", r.response.length)
                    } else {
                        console.warn("File was empty, removing from list:", data.fileName);
                        model.remove(index)
                    }
                    model.sync()
                } else {
                    console.warn("Filedata load failed:", JSON.stringify(r.response));
                }
            }
        }
    }

    function pasteFile(model, index, url, expire) {
        var data = model.get(index)
        WorkerScript.sendMessage({ event: "uploading",  file: data.fileName})
        var r = new XMLHttpRequest()
        r.open('POST', url);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        r.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        const fileContent = data["dataStr"]
        console.assert( (fileContent.length>0), "Trying to upload empty log data")

        const payload =
            'expiry_days=' + expire
            + '&title='    + data.fileName
            + '&content='  + encodeURIComponent(fileContent)
        r.send(payload);

        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                //if (r.status === 200 || r.status == 0) {
                if (r.status === 200) {
                    console.info("upload successful:", data["fileName"],  r.response);
                    model.setProperty(index, "pastedUrl", r.response.replace(/"/g, ""))
                    model.sync();
                    WorkerScript.sendMessage({ event: "pasteOk"})
                } else {
                    console.warn("error in processing request.", r.status, r.statusText);
                    WorkerScript.sendMessage({ event: "pasteError", code: r.status, text: r.statusText })
                }
            }
        }
        WorkerScript.sendMessage({ event: "uploading",  file: ""})
    }
}
// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
