import {checkDbConnection, fetchAndDisplayTable} from './commonScripts.js';

// Fetch Items from DB
async function fetchAndDisplayItems() {
    await fetchAndDisplayTable('personal', '/items');
}

async function fetchAndPopulateItemType(elementId) {
    const selectElement  = document.getElementById(elementId);

    const response = await fetch('/itemtype', {
        method: 'GET'
    });

    const responseData = await response.json();
    const itemTypeContent = responseData.data;

    selectElement.innerHTML = `<option value="0">Select Type:</option>`;

    itemTypeContent.forEach(item => {
        const option = document.createElement('option');
        option.value = item;
        option.textContent = item;
        // Populate both select elements
        selectElement.appendChild(option.cloneNode(true));
    });
}

// Fetch ItemType and populate for fitler selection
async function fetchAndPopulateItemTypes() {
    await fetchAndPopulateItemType('itemtypes1');
    await fetchAndPopulateItemType('itemtypes2');
}

// Display item count filtered by selected type

async function fetchAndDisplayItemCountByType(event) {
    event.preventDefault();

    const selectedType = document.getElementById('itemtypes1').value;

    let url = '/item-count';
    if (selectedType && selectedType !== "0") {
        url += `?itemtype=${encodeURIComponent(selectedType)}`;
    }

    const response = await fetch(url, { method: 'GET' });
    const responseData = await response.json();

    const tableElement = document.getElementById('itemCountsTable');
    const tableBody = tableElement.querySelector('tbody');

    // Clear old data
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    // Populate the table with new data
    responseData.data.forEach(item => {
        const row = tableBody.insertRow();

        // item[0] is the Item Type, item[1] is the Item Count
        const itemTypeCell = row.insertCell(0);
        itemTypeCell.textContent = item[0];

        const itemCountCell = row.insertCell(1);
        itemCountCell.textContent = item[1];
    });
}

// Fetch Poke Mart Items from DB

async function fetchAndDisplayPokeMart() {
    const tableElement = document.getElementById('pokemart');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/pokemart', {
        method: 'GET'
    });

    const responseData = await response.json();
    const itemContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    itemContent.forEach(item => {
        const row = tableBody.insertRow();
        item.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

// Display Poke Mart based on Type and Min (from user input)

async function fetchAndDisplayPokemartByTypeAndMin(event) {
    event.preventDefault();

    const selectedType = document.getElementById('itemtypes2').value;
    const minQuantity = document.getElementById('minQuantity').value;

    let url = '/pokemartbytypeandmin';

    if (selectedType && selectedType !== "0") {
        url += `?itemType=${encodeURIComponent(selectedType)}`;
    }

    if (minQuantity) {
        // If itemType was already added, use '&', else use '?' - this ensures correct formatting
        url += (url.includes('?') ? '&' : '?') + `minQuantity=${encodeURIComponent(minQuantity)}`;
    }

    const response = await fetch(url, { method: 'GET' });
    const responseData = await response.json();

    const tableElement = document.getElementById('pokemartTable');
    const tableBody = tableElement.querySelector('tbody');

    // Clear old data
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    // Populate the table with new data
    responseData.data.forEach(item => {
        const row = tableBody.insertRow();

        // item[0] is the Location Name, item[1] is the Region Name, item[2] is Item Type, item[3] is Item Quantity
        const locationCell = row.insertCell(0);
        locationCell.textContent = item[0];

        const regionCell = row.insertCell(1);
        regionCell.textContent = item[1];

        const itemTypeCell = row.insertCell(2);
        itemTypeCell.textContent = item[2];

        const itemQuantityCell = row.insertCell(3);
        itemQuantityCell.textContent = item[3];
    });
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchAndDisplayItems();
    fetchAndPopulateItemTypes();
    fetchAndDisplayPokeMart();
    document.getElementById('filterCountsByType').addEventListener('submit', fetchAndDisplayItemCountByType);
    document.getElementById('quantityFilterForm').addEventListener('submit', fetchAndDisplayPokemartByTypeAndMin);
};
