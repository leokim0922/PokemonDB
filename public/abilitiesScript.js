import { checkDbConnection, fetchAndDisplayTable} from './commonScripts.js';

async function fetchAndDisplayAbilities() {
    await fetchAndDisplayTable('abilityTable', '/abilities');
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchTableData();
};

// General function to refresh the displayed table data.
// Invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayAbilities();
}