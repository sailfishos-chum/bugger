/*
 * 
 */
.pragma library

var storage = "";

function store(obj) {
	console.debug("storing:\n", JSON.stringify(obj));
}
function restore() {
	console.debug("restoring:\n");
}
