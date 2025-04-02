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

router.get('/abilities', async (req, res) => {
    const tableContent = await appService.fetchAbilitiesFromDb();
    res.json({data: tableContent});
});

router.get('/pokemonid', async (req, res) => {
    const tableContent = await appService.fetchPokemonIDFromDb();
    res.json({data: tableContent});
});

router.get('/types', async (req, res) => {
    const tableContent = await appService.fetchTypesEffectFromDb();
    res.json({data: tableContent});
});

router.get('/gym', async (req, res) => {
    const tableContent = await appService.fetchGymTrainersFromDb();
    res.json({data: tableContent});
});

router.get('/calculateAvgWinningAggregate', async (req, res) => {
    const tableContent = await appService.fetchAverageWinningAggregate();
    res.json({data: tableContent});
});

router.get('/moves', async (req, res) => {
    try {
        const attributes = req.query.attributes ? req.query.attributes.split(',') : [];
        if (attributes.length === 0) {
            return res.status(400).json({ error: 'No attributes provided' });
        }

        const tableContent = await appService.fetchMoveAttributesFromDb(attributes);
        res.json({ data: tableContent });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/typeEffect', async (req, res) => {
    try {
        const parameters = req.query.attributes ? req.query.attributes.split(',') : [];
        if (parameters.length === 0) {
            return res.status(400).json({ error: 'No attributes provided' });
        }

        const tableContent = await appService.fetchTypesEffectParamsFromDb(parameters);
        res.json({ data: tableContent });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
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

router.get('/items', async (req, res) => {
    const tableContent = await appService.fetchItemFromDB();
    res.json({data: tableContent});
});

// router.get('/itemname', async (req, res) => {
//     console.log("Database connection established!");
//     const tableContent = await appService.fetchItemNameFromDb();
//     res.json({data: tableContent});
// });

router.get('/itemtype', async (req, res) => {
    const tableContent = await appService.fetchItemTypeFromDb();
    res.json({data: tableContent});
});

// router.get('/itemeffect', async (req, res) => {
//     const tableContent = await appService.fetchItemEffectFromDb();
//     res.json({data: tableContent});
// });

router.get('/item-count', async (req, res) => {
    const { itemtype } = req.query;
    const tableContent = await appService.fetchItemCountByType(itemtype);
    res.json({data: tableContent});
});

router.get('/pokemart', async (req, res) => {
    const tableContent = await appService.fetchMartFromDB();
    res.json({data: tableContent});
});

router.get('/pokemartbytypeandmin', async (req, res) => {
    const itemType = req.query.itemType
    const minQuantity = req.query.minQuantity //minQuantity is still a string here
    const tableContent = await appService.fetchPokeMartByTypeAndMin(itemType, minQuantity);
    res.json({data: tableContent});
});


module.exports = router;