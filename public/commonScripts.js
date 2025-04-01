// checks db connection
export async function checkDbConnection() {
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

// Fetches typenames from Type table and become selection options.
export async function fetchAndPopulateTypeName(elementId = 'insertTypeName') {
    const selectElement  = document.getElementById(elementId);

    const response = await fetch('/typename', {
        method: 'GET'
    });

    const responseData = await response.json();
    const typenameContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (selectElement) {
        selectElement.innerHTML = `
                <option value='All'>Select Type:</option>
        `;
    }

    typenameContent.forEach(typename => {
        const option = document.createElement('option');
        option.value = typename;  // Use ID as the value
        option.textContent = typename; // Display type name
        selectElement.appendChild(option);
    });
}

export async function fetchAndDisplayTable(elementID, input) {
    const tableElement = document.getElementById(elementID);
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch(input, {
        method: 'GET'
    });

    const responseData = await response.json();
    const content = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    content.forEach(subContent => {
        const row = tableBody.insertRow();
        subContent.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}