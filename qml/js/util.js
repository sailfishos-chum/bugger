/*
 * Utilities for loading and saving - form data in this case
 */
.pragma library
.import QtQuick.LocalStorage 2.0 as LS

var db_initialized = false;

/** Save an object
 *
 * @param {object}  obj object to store
 */
function store(obj) {
    save(obj);
}
/** Load an object
 *
 * @param {url} loc         path to storage location (cache)
 */
function restore(loc) {
    return load();
}
function reset() { resetDefault() }

/* 
 * **** INTERNAL FUNCTIONS ****
 */

// TODO: do a proper de/obfuscation
function obfuscate(data) {
    return Qt.btoa(unescape(encodeURIComponent(data)));
}
function defuscate(data) {
    return decodeURIComponent(escape(Qt.atob(data)));
}


function getDb() {
    var db = LS.LocalStorage.openDatabaseSync("Storage", "0.2", "Persistent Storage", 10000);
    if (!db_initialized) {
        db_initialized = true;
        initDb(db);
    }
    return db;
}
function initDb(db) {
    console.debug("Init DB");
    try {
        db.transaction(function(tx) {
            //tx.executeSql('CREATE TABLE IF NOT EXISTS SavedContent( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT, post TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS AutoSaved(post TEXT)');
        })
    } catch (err) {
        console.warn("Error creating or adding table in database: " + err);
    }
}
function clearDb(db) {
    try {
        db.transaction(function(tx) {
            tx.executeSql('DROP TABLE AutoSaved');
        })
    } catch (err) {
        console.warn("Error creating table in database: " + err);
    }
}
function dropDb(db) {
    try {
        db.transaction(function(tx) {
            tx.executeSql('DROP DATABASE');
        })
    } catch (err) {
        console.warn("Error creating table in database: " + err);
    }}

function resetAutoSaved(){
    var db = getDb();
    try {
        db.transaction( function(tx) {
                var rs = tx.executeSql('DROP TABLE AutoSaved');
        })
    } catch (err) {
        console.warn("Error executing transaction: " + err);
    }
}

/** Load an obfuscated JSON string of data from database.
 *
 */
function load(){
    console.debug("Load from DB");
    var db = getDb();
    var ret = "";
    try {
        db.readTransaction(function(tx) {
            var rs = tx.executeSql('SELECT post FROM AutoSaved LIMIT 1');
            var r = rs.rows.item(0).post;
            ret = defuscate(r);
        })
    } catch (err) {
        console.warn("Error executing transaction: " + err);
        return "";
    }
    return ret;
}

/** Store an obfuscated JSON string of data to database.
 *
 * @param {string} data         JSON data
 */
function save(data){
    console.debug("Saving to DB");
    var odata = obfuscate(JSON.stringify(data))
    var db = getDb();
    try {
        db.transaction( function(tx) {
            tx.executeSql('DELETE from AutoSaved');
            tx.executeSql('INSERT INTO AutoSaved VALUES(?)', [ odata ]);
        })
    } catch (err) {
        console.warn("Error executing transaction: " + err);
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
