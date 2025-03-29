const express = require('express');
const appService = require('./appService');

const router = express.Router();

// API endpoints
router.get('/check-db-connection', async (req, res) => {
    const isConnect = await appService.testOracleConnection();
    if (isConnect) {
        res.send('connected');
    } else {
        res.send('unable to connect');
    }
});

router.get('/pokemon', async (req, res) => {
    const tableContent = await appService.fetchPokemonFromDb();
    res.json({data: tableContent});
});

router.get('/typename', async (req, res) => {
    const tableContent = await appService.fetchTypeNameFromDb();
    res.json({data: tableContent});
});

router.get('/moveid', async (req, res) => {
    const tableContent = await appService.fetchMoveIDFromDb();
    res.json({data: tableContent});
});

router.get('/abilityid', async (req, res) => {
    const tableContent = await appService.fetchAbilityIDFromDb();
    res.json({data: tableContent});
});

router.get('/pokemonid', async (req, res) => {
    const tableContent = await appService.fetchPokemonIDFromDb();
    res.json({data: tableContent});
});

//insert pokemon
router.post("/insert-pokemon", async (req, res) => {
    const { pokemonid, pokemondescription, pokemonname, typename, abilityID, moveID } = req.body;
    const insertResult = await appService.insertPokemon(pokemonid, pokemondescription, pokemonname, typename, abilityID, moveID);
    if (insertResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

//delete pokemon
router.post("/delete-pokemon", async (req, res) => {
    const { pokemonid } = req.body;
    const deleteResult = await appService.deletePokemon(pokemonid);
    if (deleteResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

module.exports = router;