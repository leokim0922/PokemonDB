import {checkDbConnection, fetchAndDisplayTable} from './commonScripts.js';

async function fetchAndDisplayTrainers() {
    await fetchAndDisplayTable('gymTable', '/gym');
}

async function fetchAverageWinnings() {
    const avgNumber = document.getElementById('avgNumber');
    const operator = document.getElementById('insertOperatorWinnings').value;
    const queryParams = new URLSearchParams({ attributes: operator });

    try {
        const response = await fetch(`/calculateAvgWinningAggregate?${queryParams.toString()}`,
            { method: 'GET' });
        const data = await response.json();

        avgNumber.style.display = 'inline';

        // Extract the number from the nested array structure
        avgNumber.textContent = data.data[0][0];
    } catch (error) {
        avgNumber.textContent = 'Error calculating averages';
    }
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchAndDisplayTrainers();
    document.getElementById('filterGymsByWinnings').addEventListener('click', fetchAverageWinnings);
};