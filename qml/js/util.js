/*
 * 
 */
.pragma library

var filename = "store.dat";
var calledBy;

function registerCaller(who){
	calledBy = who;
}

function store(loc, obj) {
	console.debug("storing:\n");
	save(loc + "/" + filename,obj);
}
function restore(loc) {
	console.debug("restoring:\n");
	load(loc + "/" + filename);
}

function handleData(data) {
	console.info("Got: " + data );
	var ddata = defuscate(JSON.parse(data).content);
	console.info("Got decoded: " + ddata );
	//emit signal to caller:
	calledBy.dataLoaded(ddata);
}

// TODO: do a proper de/obfuscation
function obfuscate(data) {
	//return Qt.btoa(unescape(encodeURIComponent(data)));
	return Qt.btoa(encodeURIComponent(data));
}
function defuscate(data) {
	//return decodeURIComponent(escape(Qt.atob(data)));
	return decodeURIComponent(Qt.atob(data));
}

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
