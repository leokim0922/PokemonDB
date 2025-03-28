const express = require('express');
const appService = require('./appService');

const router = express.Router();

// API endpoints
router.get('/pokemon', async (req, res) => {
    const tableContent = await appService.fetchPokemonFromDb();
    res.json({data: tableContent});
});

module.exports = router;