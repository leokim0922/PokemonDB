import { checkDbConnection, fetchAndPopulateTypeName } from './commonScripts.js';

function getCheckedMoves() {
    const checkedMoves = ['moveid'];

    if (document.getElementById('moveName').checked) {
        checkedMoves.push('moveName');
    }

    if (document.getElementById('Power').checked) {
        checkedMoves.push('Power');
    }

    if (document.getElementById('Accuracy').checked) {
        checkedMoves.push('Accuracy');
    }

    if (document.getElementById('PowerPoints').checked) {
        checkedMoves.push('PowerPoints');
    }

    if (document.getElementById('Effect').checked) {
        checkedMoves.push('moveEffect');
    }

    if (document.getElementById('Type').checked) {
        checkedMoves.push('TypeName');
    }

    return checkedMoves;
}

// Fetches moveID from Move table and become selection options.
async function fetchAndDisplayMoves() {
    const tableElement = document.getElementById('movesTable');
    const tableRows = tableElement.querySelector('tr');
    const tableBody = tableElement.querySelector('tbody');

    const checkedAttributes = getCheckedMoves();

    // Always clear old, already fetched data before new fetching process.
    if (tableRows) {
        tableRows.innerHTML = '<th style="width:3%">ID</th>';

        checkedAttributes.forEach(function (attribute) {
            if (attribute === 'moveName') {
                tableRows.insertCell().outerHTML = '<th style="width:10%">Move</th>';
            } else if (attribute === 'PowerPoints') {
                tableRows.insertCell().outerHTML = '<th style="width:10%">PP</th>';
            } else if (attribute === 'TypeName') {
                tableRows.insertCell().outerHTML = '<th style="width:10%">Type</th>';
            } else if (attribute === 'moveEffect') {
                tableRows.insertCell().outerHTML = '<th style="width:10%">Effect</th>';
            } else {
                tableRows.insertCell().outerHTML = '<th style="width:10%">' + attribute + '</th>';
            }
        });
    }

    const queryParams = new URLSearchParams({ attributes: checkedAttributes.join(',') });

    const response = await fetch(`/moves?${queryParams.toString()}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });

    const responseData = await response.json();
    const moveContent = responseData.data;

    // Clear old body, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    moveContent.forEach(move => {
        const row = tableBody.insertRow();
        move.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

function addEventListenerToCheckBoxes() {
    var checkboxes = document.querySelectorAll("input[type=checkbox][class=moveCheck]");
    checkboxes.forEach(function(checkbox) {
        checkbox.addEventListener('change', fetchAndDisplayMoves)
    });
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchAndPopulateTypeName();
    fetchTableData();
    addEventListenerToCheckBoxes();
};

// General function to refresh the displayed table data.
// Invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayMoves();
}