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

// Fetches typenames from Type table and become selection options.
async function fetchAndPopulateTypeName() {
    const selectElement = document.getElementById('insertTypeName');

    const response = await fetch('/typename', {
        method: 'GET'
    });

    const responseData = await response.json();
    const typenameContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (selectElement) {
        selectElement.innerHTML = `
                <option value="0">Select Type:</option>
        `;
    }
}

// checks db connection
async function checkDbConnection() {
    const statusElem = document.getElementById('dbStatus');

    const response = await fetch('/check-db-connection', {
        method: "GET"
    });

    // Display the statusElem's text in the placeholder.
    statusElem.style.display = 'inline';

    response.text()
        .then((text) => {
            statusElem.textContent = text;
        })
        .catch((error) => {
            statusElem.textContent = 'connection timed out';  // Adjust error handling if required.
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