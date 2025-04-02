import {checkDbConnection, fetchAndDisplayTable} from './commonScripts.js';

async function fetchAndDisplayTrainers() {
    await fetchAndDisplayTable('gymTable', '/gym');
}

async function fetchAverageWinnings() {
    const avgNumber = document.getElementById('avgNumber');

    const response = await fetch('/calculateAvgWinning', {
        method: 'GET'
    });

    avgNumber.style.display = 'inline';

    response.text()
        .then((text) => {
            avgNumber.textContent = text;
        })
        .catch((error) => {
            avgNumber.textContent = 'error calculating averages';  // Adjust error handling if required.
        });
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchAndDisplayTrainers();
    document.getElementById('filterGymsByWinnings').addEventListener('submit', fetchAverageWinnings);
};