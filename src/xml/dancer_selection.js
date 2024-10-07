
function deselect_all() {
    for (e of document.querySelectorAll("svg .dancer")) {
        console.log("deselect ", e);
    }
}

function select_dancers(dancer_ids) {
    deselect_all();
    for (id of dancer_ids) {
        d = document.getElementById(id);
        console.log("select ", id, d);
    }
}

