const oracledb = require('oracledb');
const loadEnvFile = require('./utils/envUtil');

const envVariables = loadEnvFile('./.env');

// Database configuration setup. Ensure your .env file has the required database credentials.
const dbConfig = {
    user: envVariables.ORACLE_USER,
    password: envVariables.ORACLE_PASS,
    connectString: `${envVariables.ORACLE_HOST}:${envVariables.ORACLE_PORT}/${envVariables.ORACLE_DBNAME}`,
    poolMin: 1,
    poolMax: 3,
    poolIncrement: 1,
    poolTimeout: 60
};


// initialize connection pool
async function initializeConnectionPool() {
    try {
        await oracledb.createPool(dbConfig);
        console.log('Connection pool started');
    } catch (err) {
        console.error('Initialization error: ' + err.message);
    }
}

async function closePoolAndExit() {
    console.log('\nTerminating');
    try {
        await oracledb.getPool().close(10); // 10 seconds grace period for connections to finish
        console.log('Pool closed');
        process.exit(0);
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
}

initializeConnectionPool();

process
    .once('SIGTERM', closePoolAndExit)
    .once('SIGINT', closePoolAndExit);

// Wrapper to manage OracleDB actions, simplifying connection handling.
async function withOracleDB(action) {
    let connection;
    try {
        connection = await oracledb.getConnection(); // Gets a connection from the default pool
        return await action(connection);
    } catch (err) {
        console.error(err);
        throw err;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}

// Core functions for database operations
async function testOracleConnection() {
    return await withOracleDB(async (connection) => {
        return true;
    }).catch(() => {
        return false;
    });
}

// SELECT FROM DATABASE
async function fetchPokemonFromDb() {
    const query = 'SELECT DISTINCT p.pokemonid, p.pokemonname, b.typename, m.movename, a.abilityeffect  \n' +
        'FROM pokemon p, belongs b, possesses po, ability a, learns l, move_associates1 m\n' +
        'WHERE p.pokemonid = po.pokemonid and po.abilityid = a.abilityid and \n' +
        'p.pokemonid = b.pokemonid and p.pokemonid = l.pokemonid and l.moveid = m.moveid\n' +
        'ORDER BY p.pokemonid';
    return await fetchQuery(query);
}

// SELECT FROM DATABASE
async function fetchTypeNameFromDb() {
    const query = 'SELECT typename FROM type';
    return await fetchQuery(query);
}

// SELECT FROM DATABASE
async function fetchMoveIDFromDb() {
    const query = 'SELECT moveid FROM move_associates1';
    return await fetchQuery(query);
}

// SELECT FROM DATABASE
async function fetchAbilityIDFromDb() {
    const query = 'SELECT abilityid FROM ability ORDER BY abilityid';
    return await fetchQuery(query);
}

// SELECT FROM DATABASE
async function fetchPokemonIDFromDb() {
    const query = 'SELECT pokemonid FROM Pokemon';
    return await fetchQuery(query);
}

// SELECT Abilities from DB
async function fetchAbilitiesFromDb() {
    const query = 'SELECT * FROM Ability';
    return await fetchQuery(query);
}

// SELECT Trainer + Gyms from DB
async function fetchGymTrainersFromDb() {
    const query = 'SELECT td.locationname, td.regionname, td.trainername, td.winnings' +
        ' FROM trainer_defends td';
    return await fetchQuery(query);
}

async function fetchQuery(query, bindValues = {}) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, bindValues);
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// SELECT & JOIN Types + Effect from DB
async function fetchTypesEffectFromDb() {
    const query = 'SELECT t.Typename, t.typeDescription, e.percentage, e.typename2 ' +
        'FROM Type t, Effect e WHERE t.TypeName = e.TypeName1';
    return await fetchQuery(query);
}

// SELECT & JOIN Types + Effect from DB
async function fetchTypesEffectParamsFromDb(parameters) {
    var query = 'SELECT t.Typename, t.typeDescription, e.percentage, e.typename2 ' +
        'FROM Type t, Effect e WHERE t.TypeName = e.TypeName1';

    let type = parameters[0];
    let op1 = parameters[1];
    let num1 = parameters[2];
    let logic = parameters[3];
    let op2 = parameters[4];
    let num2 = parameters[5];

    let bindValues = {};

    if (type === 'All' && op1 === 'None') {
        return fetchTypesEffectFromDb();
    }
    if (type !== 'All') {
        query = query + ' and t.Typename = :type';
        bindValues.type = type;
    }
    if (op1 !== 'None' && num1 >= 0 && num1 != '') {
        query = query + ` and (e.percentage ${op1} :num1`;
        bindValues.num1 = num1;
        if (logic === 'None') {
            query = query + ')'
        } else {
            if (op2 !== 'None' && num2 >= 0 && num2 != '') {
                query = query + ` ${logic} e.percentage ${op2} :num2)`;
                bindValues.num2 = num2;
            } else {
                query = query + ')'
            }
        }
    }

    console.log("Final Query: ", query);
    console.log("Bind Values: ", bindValues);

    try {
        return await fetchQuery(query,bindValues);
    } catch (error) {
        console.error("Error message element not found:", error.message);
    }
}

// INSERTING POKEMON & associated BELONGS, LEARNS and POSSESSES into Database
async function insertPokemon(id, description, name, type, abilityID, moveID) {
    return await withOracleDB(async (connection) => {
        // Check if type exists
        const checkType = await connection.execute(
            `SELECT COUNT(*) FROM Type t WHERE t.typeName = :type`,
            { type }
        );
        if (checkType.rows[0][0] < 1) {
            console.log('TypeName does not exist.');
            return false;
        }

        // Check if ability exists
        const checkAbility = await connection.execute(
            `SELECT COUNT(*) FROM Ability a WHERE a.AbilityID = :abilityID`,
            { abilityID }
        );
        if (checkAbility.rows[0][0] < 1) {
            console.log('Ability does not exist.');
            return false;
        }

        // Check if move exists
        const checkMove = await connection.execute(
            `SELECT COUNT(*) FROM Move_Associates1 m WHERE m.MoveID = :moveID`,
            { moveID }
        );
        if (checkMove.rows[0][0] < 1) {
            console.log('Move does not exist.');
            return false;
        }

        // Execute insert queries separately
        await connection.execute(
            `INSERT INTO Pokemon (PokemonID, PokemonName, PokemonDescription) 
             VALUES (:id, :name, :description)`,
            { id, name, description }
        );

        await connection.execute(
            `INSERT INTO Belongs (PokemonID, TypeName) 
             VALUES (:id, :type)`,
            { id, type }
        );

        await connection.execute(
            `INSERT INTO Possesses (PokemonID, AbilityID) 
             VALUES (:id, :abilityID)`,
            { id, abilityID }
        );

        await connection.execute(
            `INSERT INTO Learns (PokemonID, MoveID) 
             VALUES (:id, :moveID)`,
            { id, moveID }
        );

        await connection.commit();
        return true;
    }).catch((err) => {
        console.error(err);
        return false;
    });
}

//DELETE POKEMON FROM DATABASE
async function deletePokemon(id) {
    return await withOracleDB(async (connection) => {
          await connection.execute(
            `DELETE FROM Pokemon p WHERE p.pokemonid = :id`,
              { id });

        await connection.commit();
        return true;
    }).catch((err) => {
        console.error(err);
        return false;
    });
}

async function queryFromOracle(query, binds = {}) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(query, binds);
        return result.rows;
    }).catch(() => {
        return [];
    });
}


// PROJECTION & JOIN (join statement in SQL by creating VIEW, joining MoveAssociate_1 &
// MoveAssociate_2 to find Move's associated Type)
async function fetchMoveAttributesFromDb(attributes) {
    const typeFilter = attributes.pop();

    if (!Array.isArray(attributes) || attributes.length === 0) {
        throw new Error('Attributes must be a non-empty array');
    }

    var query = '';

    if (typeFilter === 'All') {
        query = `SELECT ${attributes} FROM Movetype`;
        return await queryFromOracle(query);
    } else {
        query = `SELECT ${attributes} FROM Movetype mt WHERE mt.typename = :typeFilter`;
        return await queryFromOracle(query, { typeFilter });
    }
}

// SELECT FROM DATABASE
async function fetchItemFromDB() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT DISTINCT io.ItemName, io2.ItemType, io.ItemEffect
            FROM Item_Owns io
            JOIN Item_Owns2 io2 ON io.ItemEffect = io2.ItemEffect
            ORDER BY io.ItemName`
        );
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// SELECT FROM DATABASE
async function fetchItemTypeFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT DISTINCT itemtype FROM item_owns2');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function fetchItemCountByType() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT io.ItemType, COUNT(i.ItemName) AS ItemCount
            FROM Item_Owns i
            JOIN Item_Owns2 io ON i.ItemEffect = io.ItemEffect
            GROUP BY io.ItemType
            ORDER BY ItemCount DESC`,
        );
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// SELECT FROM DATABASE
async function fetchMartFromDB() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT DISTINCT io.ItemName, io2.ItemType, io.ItemEffect, p.LocationName, p.RegionName
            FROM Item_Owns io
            JOIN Item_Owns2 io2 ON io.ItemEffect = io2.ItemEffect
            JOIN Sells s ON io.ItemName = s.ItemName
            JOIN Pokemart p ON s.LocationName = p.LocationName AND s.RegionName = p.RegionName
            ORDER BY io.ItemName`
        );
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// Filter Poke Marts by item type and minimum quantity
async function fetchPokeMartByTypeAndMin(itemType, minQuantity) {
    const minQuantityNum = parseInt(minQuantity, 10); // Convert minQuantity from a string to an integer (base 10)
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT 
                p.LocationName, 
                p.RegionName, 
                io2.ItemType, 
                COUNT(s.ItemName) AS ItemQuantity
            FROM 
                Item_Owns io
            JOIN 
                Item_Owns2 io2 ON io.ItemEffect = io2.ItemEffect
            JOIN 
                Sells s ON io.ItemName = s.ItemName
            JOIN 
                Pokemart p ON s.LocationName = p.LocationName AND s.RegionName = p.RegionName
            WHERE 
                io2.ItemType = :itemType
            GROUP BY 
                p.LocationName, p.RegionName, io2.ItemType
            HAVING 
                COUNT(s.ItemName) >= :minQuantity
            ORDER BY 
                p.LocationName`,
            { itemType, minQuantity: minQuantityNum }
        );
        console.log(result)
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// NESTED AGGREGATION with GROUP BY
async function fetchAverageWinningAggregate(operator) {
    const query = 'SELECT AVG(td.winnings) FROM trainer_defends td WHERE td.winnings' + operator +
        'ALL (SELECT AVG(td2.winnings) FROM trainer_defends td2 GROUP BY td2.locationname, td2.regionname)';
    return await fetchQuery(query);
}


module.exports = {
    testOracleConnection,
    fetchPokemonFromDb,
    fetchTypeNameFromDb,
    fetchMoveIDFromDb,
    fetchAbilityIDFromDb,
    fetchPokemonIDFromDb,
    deletePokemon,
    insertPokemon,
    fetchMoveAttributesFromDb,
    fetchTypesEffectFromDb,
    fetchTypesEffectParamsFromDb,
    fetchAbilitiesFromDb,
    fetchItemTypeFromDb,
    fetchItemFromDB,
    fetchItemCountByType,
    fetchMartFromDB,
    fetchPokeMartByTypeAndMin,
    fetchGymTrainersFromDb,
    fetchAverageWinningAggregate
};