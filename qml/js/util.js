/*
 * Utilities for loading and saving - form data in this case
 */
.pragma library

/** filename for field data storage */
var filename = "store.dat";

/* 
 * **** PUBLIC FUNCTIONS ****
 */

/** Register object to receive signals
 *
 * For loading, we use a signal in QML to give back the data.
 * use this register function to set the object which has the signal (and
 * handler).
 *
 * @param {var} who     Callee.
 */
var calledBy;
function registerCaller(who){
    calledBy = who;
}

/** Save an object at location.
 *
 * @param {url}     loc path to storage location (cache)
 * @param {object}  obj object to store
 */
function store(loc, obj) {
    console.debug("storing:\n");
    save(loc + "/" + filename,obj);
}
/** Load an object from location.
 *
 * @param {url} loc         path to storage location (cache)
 */
function restore(loc) {
    console.debug("restoring:\n");
    load(loc + "/" + filename);
}

/* 
 * **** INTERNAL FUNCTIONS ****
 */

/**
 * Callback to receive data from load(), and signal the caller that it's ready.
 *
 * @param {string} data         JSON data
 */
function handleData(data) {
    var ddata = defuscate(JSON.parse(data).content);
    //emit signal to caller:
    calledBy.dataLoaded(ddata);
}

// TODO: do a proper de/obfuscation
function obfuscate(data) {
    return Qt.btoa(unescape(encodeURIComponent(data)));
}
function defuscate(data) {
    return decodeURIComponent(escape(Qt.atob(data)));
}

/** Load an obfuscated JSON string of data from location.
 *
 * @param {url}    fileUrl      full url to storage location
 */
function load(fileUrl){
    var r = new XMLHttpRequest();
    r.open('GET', fileUrl);
    r.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
    r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    r.send();

    r.onreadystatechange = function(event) {
            if (r.readyState == XMLHttpRequest.DONE) {
                    console.debug("request done.");
                    handleData(r.response);
            }
    }
    console.info("Read from: " + fileUrl + " into " + Qt.application.name );
    return data;
}
/** Store an obfuscated JSON string of data to location.
 *
 * @param {url}    fileUrl      full url to storage location
 * @param {string} data         JSON data
 */
function save(fileUrl,data){
    var r = new XMLHttpRequest();
    r.open('PUT', fileUrl);
    //var rdata = JSON.stringify(data, null, 4);
    var rdata =  { 
        "content": obfuscate(JSON.stringify(data))
    }
    rdata = JSON.stringify(rdata, null, 2);
    r.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
    r.setRequestHeader('Content-length', rdata.length);
    r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    r.send(rdata);

    r.onreadystatechange = function(event) {
        if (r.readyState == XMLHttpRequest.DONE) {
            console.debug("request done.");
        }
    }
    console.info("Wrote to :" + fileUrl + " from " + Qt.application.name );
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
