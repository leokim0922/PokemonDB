import { checkDbConnection, fetchAndPopulateTypeName} from './commonScripts.js';
import { fetchAndDisplayTable } from './commonScripts.js';


// Fetches data from the Types & Effect tables and displays it.
async function fetchAndDisplayTypes() {
    await fetchAndDisplayTable('typesTable', '/types');
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
    fetchAndDisplayTypes()();
}