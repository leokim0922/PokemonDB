import { checkDbConnection, fetchAndPopulateTypeName} from './commonScripts.js';
import { fetchAndDisplayTable } from './commonScripts.js';


// Fetches data from the Types & Effect tables and displays it.
async function fetchAndDisplayTypes() {
    await fetchAndDisplayTable('typesTable', '/types');
}

function getParameters() {
    var parameters = [];
    parameters.push(document.getElementById("insertTypeName").value);
    parameters.push(document.getElementById("operator").value);
    parameters.push(document.getElementById("effectiveness").value);
    parameters.push(document.getElementById("logic").value);
    parameters.push(document.getElementById("operator2").value);
    parameters.push(document.getElementById("effectiveness2").value);
    return parameters;
}

async function filterTableByAttributes () {
    const tableElement = document.getElementById('typesTable');
    const tableBody = tableElement.querySelector('tbody');

    var parameters = getParameters();

    const queryParams = new URLSearchParams({ attributes: parameters.join(',') });

    const response = await fetch(`/typeEffect?${queryParams.toString()}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });

    const responseData = await response.json();
    const content = responseData.data;

    // Clear old body, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    content.forEach(type => {
        const row = tableBody.insertRow();
        type.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

function addEventListenerToFilterButton() {
    document.getElementById("filterAttributes").addEventListener("submit", filterTableByAttributes)
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchAndPopulateTypeName();
    fetchTableData();
    addEventListenerToFilterButton();
};

// General function to refresh the displayed table data.
// Invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayTypes();
}