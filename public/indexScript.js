import { checkDbConnection, fetchAndPopulateTypeName } from './commonScripts.js';
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


// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchTableData();
    fetchAndPopulateTypeName();
    fetchAndPopulateMoveID();
    fetchAndPopulateAbilityID();
    fetchAndPopulatePokemonID();
    document.getElementById("insertPokemon").addEventListener("submit", insertPokemon);
    document.getElementById("deletePokemon").addEventListener("submit", deletePokemon);
};

// General function to refresh the displayed table data.
// Invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayPokemon();
    fetchAndPopulatePokemonID();
}

