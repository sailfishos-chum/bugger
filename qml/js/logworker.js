// Copyright (c) 2023 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0

.pragma library

WorkerScript.onMessage = function(m) {
    if (m.action === "pasteFile")    pasteFile(m.model, m.index, m.url, m.expire)
    if (m.action === "loadAndPaste") loadAndPaste(m.model, m.url, m.expire)

    function loadAndPaste(model, url, expire) {
        if (!model) return
        for (var i = 0; i < model.count; ++i) {
           console.debug("Uploading %1/%2".arg(i+1).arg(model.count))
           loadAndPasteFile(model, i, url, expire)
        }
    }

    /* get contents from name, upload */
    function loadAndPasteFile(model, index, url, expire) {
        var fn = model.get(index).url
        console.assert((fn.length > 0), "No filepath in element.")
        var r = new XMLHttpRequest();
        r.open('GET', fn);
        r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        r.send();
        r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                if (r.status === 200) {
                    WorkerScript.sendMessage({ event: "readOk", count: r.response.length })
                    uploadFile(r.response)
                } else {
                    console.warn("Filedata load failed:", JSON.stringify(r.response));
                    WorkerScript.sendMessage({ event: "readError", file: model.get(index).fileName, code: r.status, text: r.statusText ? r.statusText : "Unknown Error" })
                }
            }
        }

        function uploadFile(fileContent) {
            console.assert( (fileContent.length>0), "Trying to upload empty log data");
            WorkerScript.sendMessage({ event: "uploading",  file: model.get(index).fileName })
            console.debug("uploading %1 to %2, expiring in %3s".arg(model.get(index).fileName).arg(url).arg(expire))
            var r = new XMLHttpRequest();
            r.open('POST', url);
            r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
            r.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

            const payload =
                'expiry_days=' + expire
                + '&title='    + model.get(index).fileName
                + '&content='  + encodeURIComponent(fileContent);
            r.send(payload);

            r.onreadystatechange = function(event) {
                if (r.readyState == XMLHttpRequest.DONE) {
                    if (r.status === 200) {
                        console.info("upload successful:", r.response);
                        const ret = r.response.split('"').join(''); // remove quotes
                        model.setProperty(index, "pastedUrl", ret);
                        model.sync();
                        WorkerScript.sendMessage({ event: "pasteOk", file: model.get(index).fileName, url: ret })
                    } else {
                        WorkerScript.sendMessage({ event: "pasteError", file: model.get(index).fileName, code: r.status, text: r.statusText ? r.statusText : "Unknown Error" })
                        console.warn("error in processing request.", r.status, r.statusText);
                    }
                }
            }
        }
    }
}
// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
