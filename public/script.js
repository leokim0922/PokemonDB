function fetchTableData() {
    fetchAndDisplayPokemon();
}


// Fetches data from the pokemon table and displays it.
async function fetchAndDisplayPokemon() {
    const tableElement = document.getElementById('pokemon');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/pokemon', {
        method: 'GET'
    });

    const responseData = await response.json();
    const pokemonContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    pokemonContent.forEach(user => {
        const row = tableBody.insertRow();
        user.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}
