import {checkDbConnection, fetchAndPopulateTypeName} from './commonScripts.js';
import { fetchAndDisplayTable } from './commonScripts.js';


// Fetches data from the pokemon table and displays it.
async function fetchAndDisplayPokemon() {
    await fetchAndDisplayTable('pokemon', '/pokemon');
}

// Fetches MoveID from Move table and become selection options.
async function fetchAndPopulateMoveID() {
    const selectElement  = document.getElementById('insertMoveID');

    const response = await fetch('/moveid', {
        method: 'GET'
    });

    const responseData = await response.json();
    const moveIDContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (selectElement) {
        selectElement.innerHTML = `
                <option value="0">Select Type:</option>
        `;
    }

    moveIDContent.forEach(moveid => {
        const option = document.createElement('option');
        option.value = moveid;  // Use ID as the value
        option.textContent = moveid; // Display type name
        selectElement.appendChild(option);
    });
}

// Fetches AbilityID from Ability table and become selection options.
async function fetchAndPopulateAbilityID() {
    const selectElement  = document.getElementById('insertAbilityID');

    const response = await fetch('/abilityid', {
        method: 'GET'
    });

    const responseData = await response.json();
    const abilityIDContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (selectElement) {
        selectElement.innerHTML = `
                <option value="0">Select Type:</option>
        `;
    }

    abilityIDContent.forEach(abilityID => {
        const option = document.createElement('option');
        option.value = abilityID;  // Use ID as the value
        option.textContent = abilityID; // Display type name
        selectElement.appendChild(option);
    });
}

// Fetches PokemonID from Pokemon table and become selection options.
async function fetchAndPopulatePokemonID() {
    const selectElement  = document.getElementById('insertPokemonID');

    const response = await fetch('/pokemonid', {
        method: 'GET'
    });

    const responseData = await response.json();
    const PokemonIDContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (selectElement) {
        selectElement.innerHTML = `
                <option value="0">Select PokemonID:</option>
        `;
    }

    PokemonIDContent.forEach(PokemonID => {
        const option = document.createElement('option');
        option.value = PokemonID;  // Use ID as the value
        option.textContent = PokemonID; // Display type name
        selectElement.appendChild(option);
    });
}

// Inserts new pokemon
async function insertPokemon(event) {
    event.preventDefault();

    const idValue = document.getElementById('insertId').value;
    const nameValue = document.getElementById('insertName').value;
    const descriptionValue = document.getElementById('insertDescription').value;
    const typeNameValue = document.getElementById('insertTypeName').value;
    const abilityIDValue = document.getElementById('insertAbilityID').value;
    const moveIDValue = document.getElementById('insertMoveID').value;

    const response = await fetch('/insert-pokemon', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            pokemonid: idValue,
            pokemondescription: descriptionValue,
            pokemonname: nameValue,
            typename: typeNameValue,
            abilityID: abilityIDValue,
            moveID: moveIDValue
        })
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('insertResultMsg');

    if (responseData.success) {
        messageElement.textContent = "Data inserted successfully!";
        fetchTableData();
    } else {
        messageElement.textContent = "Error inserting data!";
    }
}

// deletes pokemon by ID
async function deletePokemon(event) {
    event.preventDefault();

    const idValue = document.getElementById('insertPokemonID').value;

    const response = await fetch('/delete-pokemon', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            pokemonid: idValue
        })
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('deleteResultMsg');

    if (responseData.success) {
        messageElement.textContent = "Data deleted successfully!";
        fetchTableData();
    } else {
        messageElement.textContent = "Error deleting data!";
    }
}

//START ITEMS JS FILE

// Fetch Items from DB

async function fetchAndDisplayItems() {
    const tableElement = document.getElementById('personal');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/items', {
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

// Fetch ItemType and populate for fitler selection
async function fetchAndPopulateItemType() {
    const selectElement1  = document.getElementById('itemtypes1');
    const selectElement2  = document.getElementById('itemtypes2');

    const response = await fetch('/itemtype', {
        method: 'GET'
    });

    const responseData = await response.json();
    const itemTypeContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (selectElement1) {
        selectElement1.innerHTML = `
            <option value="0">Select Type:</option>
        `;
    }
    if (selectElement2) {
        selectElement2.innerHTML = `
            <option value="0">Select Type:</option>
        `;
    }

    itemTypeContent.forEach(item => {
        const option = document.createElement('option');
        option.value = item;
        option.textContent = item;
        // Populate both select elements
        if (selectElement1) selectElement1.appendChild(option.cloneNode(true));
        if (selectElement2) selectElement2.appendChild(option.cloneNode(true));
    });
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
    if (window.location.pathname === '/index.html') {
    fetchTableData();
    fetchAndPopulateTypeName();
    fetchAndPopulateMoveID();
    fetchAndPopulateAbilityID();
    fetchAndPopulatePokemonID();
    document.getElementById("insertPokemon").addEventListener("submit", insertPokemon);
    document.getElementById("deletePokemon").addEventListener("submit", deletePokemon);
    } else if (window.location.pathname === '/pokemarts.html') {
        fetchAndDisplayItems();
        fetchAndPopulateItemType();
        fetchAndDisplayPokeMart();
        document.getElementById('filterCountsByType').addEventListener('submit', fetchAndDisplayItemCountByType);
        document.getElementById('quantityFilterForm').addEventListener('submit', fetchAndDisplayPokemartByTypeAndMin);
    }
};

// General function to refresh the displayed table data.
// Invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayPokemon();
    fetchAndPopulatePokemonID();
}

