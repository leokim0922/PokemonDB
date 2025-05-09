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

function buildColumnNames(checkedAttributes, tableRows) {
    checkedAttributes.forEach(function (attribute) {
        if (attribute === 'moveid') {

        } else if (attribute === 'moveName') {
            tableRows.insertCell().outerHTML = '<th style="width:5%">Move</th>';
        } else if (attribute === 'PowerPoints') {
            tableRows.insertCell().outerHTML = '<th style="width:1%">PP</th>';
        } else if (attribute === 'TypeName') {
            tableRows.insertCell().outerHTML = '<th style="width:10%">Type</th>';
        } else if (attribute === 'moveEffect') {
            tableRows.insertCell().outerHTML = '<th style="width:10%">Effect</th>';
        } else {
            tableRows.insertCell().outerHTML = '<th style="width:5%">' + attribute + '</th>';
        }
    });
}

async function fetchAndDisplayMoves(type = 'All') {
    const tableElement = document.getElementById('movesTable');
    const tableRows = tableElement.querySelector('tr');
    const tableBody = tableElement.querySelector('tbody');

    const checkedAttributes = getCheckedMoves();

    // Always clear old, already fetched data before new fetching process.
    if (tableRows) {
        tableRows.innerHTML = '<th style="width:3%">ID</th>';
        buildColumnNames(checkedAttributes, tableRows);
    }

    checkedAttributes.push(type);
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

function fetchAndDisplayMovesWithType() {
    const typeValue = document.getElementById('insertTypeName').value;
    fetchAndDisplayMoves(typeValue);
}

function addEventListenerToCheckBoxes() {
    var checkboxes = document.querySelectorAll("input[type=checkbox][class=moveCheck]");
    checkboxes.forEach(function(checkbox) {
        checkbox.addEventListener('change', fetchAndDisplayMovesWithType)
    });
}

function addEventListenerToTypeDropdown() {
    document.getElementById("insertTypeName").addEventListener("change", fetchAndDisplayMovesWithType);
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchAndPopulateTypeName();
    fetchTableData();
    addEventListenerToCheckBoxes();
    addEventListenerToTypeDropdown();
};

// General function to refresh the displayed table data.
// Invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayMoves();
}