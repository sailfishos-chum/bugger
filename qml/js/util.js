/*
 * 
 */
.pragma library

var filename = "store.dat";

function store(loc, obj) {
	//console.debug("storing:\n", JSON.stringify(obj,null,2));
	console.debug("storing:\n");
	save(loc + "/" + filename,obj);
	return;
}
function restore(loc) {
	console.debug("restoring:\n");
	load(loc + "/" + filename);
}

function handleData(data) {
	console.info("Got: " + data );
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
	var rdata = JSON.stringify(data, null, 4);
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
