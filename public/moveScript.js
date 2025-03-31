import { checkDbConnection, fetchAndPopulateTypeName } from './commonScripts.js';

// Fetches moveID from Move table and become selection options.
async function fetchAndDisplayMoves() {
    const tableElement = document.getElementById('movesTable');
    const tableRows = tableElement.querySelector('tr');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/moves', {
        method: 'GET'
    });

    const responseData = await response.json();
    const moveContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
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

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchAndPopulateTypeName();
    fetchTableData();
};

// General function to refresh the displayed table data.
// Invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayMoves();
}