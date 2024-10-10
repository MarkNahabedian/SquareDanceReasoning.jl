
function remove_selected(elt) {
    elt.setAttribute(
        "class", elt.getAttribute("class").replace(" selected", ""));
}

function add_selected(elt) {
    elt.setAttribute(
        "class", elt.getAttribute("class") + " selected");
}

function deselect_all() {
    for (elt of document.querySelectorAll(".selected")) {
        remove_selected(elt);
    }
}

function select_dancers(event, dancer_ids) {
    deselect_all();
    add_selected(event.target);
    for (id of dancer_ids) {
        elt = document.getElementById(id);
        add_selected(elt);
    }
}

