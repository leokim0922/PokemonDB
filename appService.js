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
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT DISTINCT p.pokemonid, p.pokemonname, b.typename, m.movename, a.abilityeffect  \n' +
            'FROM pokemon p, belongs b, possesses po, ability a, learns l, move_associates1 m\n' +
            'WHERE p.pokemonid = po.pokemonid and po.abilityid = a.abilityid and \n' +
            'p.pokemonid = b.pokemonid and p.pokemonid = l.pokemonid and l.moveid = m.moveid\n' +
            'ORDER BY p.pokemonid');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// SELECT FROM DATABASE
async function fetchTypeNameFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT typename FROM type');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// SELECT FROM DATABASE
async function fetchMoveIDFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT moveid FROM move_associates1');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// SELECT FROM DATABASE
async function fetchAbilityIDFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT abilityid FROM ability');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// SELECT FROM DATABASE
async function fetchPokemonIDFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT pokemonid FROM Pokemon');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// INSERTING INTO DATABASE
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

// // SELECT FROM DATABASE
// async function fetchItemNameFromDb() {
//     return await withOracleDB(async (connection) => {
//         const result = await connection.execute('SELECT itemname FROM item_owns');
//         return result.rows;
//     }).catch(() => {
//         return [];
//     });
// }

// SELECT FROM DATABASE
async function fetchItemTypeFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT DISTINCT itemtype FROM item_owns2');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

// // SELECT FROM DATABASE
// async function fetchItemEffectFromDb() {
//     return await withOracleDB(async (connection) => {
//         const result = await connection.execute('SELECT itemeffect FROM item_owns2');
//         return result.rows;
//     }).catch(() => {
//         return [];
//     });
// }

async function fetchItemCountByType(itemtype) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT io.ItemType, COUNT(i.ItemName) AS ItemCount
            FROM Item_Owns i
            JOIN Item_Owns2 io ON i.ItemEffect = io.ItemEffect
            WHERE io.ItemType = :itemtype
            GROUP BY io.ItemType
            ORDER BY ItemCount DESC`,
            { itemtype }
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
        console.log(result)
        return result.rows;
    }).catch(() => {
        return [];
    });
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
    // fetchItemNameFromDb,
    fetchItemTypeFromDb,
    // fetchItemEffectFromDb,
    fetchItemFromDB,
    fetchItemCountByType,
    fetchMartFromDB
};