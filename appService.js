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

async function fetchTypeNameFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT typename FROM type');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function fetchMoveIDFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT moveid FROM move_associates1');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function fetchAbilityIDFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT abilityid FROM ability');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function insertPokemon(id, description, name, type, moveID, abilityID) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `BEGIN AddPokemonWithTypeAbilityLearns(:id, :description, :name, :type, :abilityID, :moveID); END; /`,
            [id, description, name, type, abilityID, moveID],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return false;
    });
}

module.exports = {
    testOracleConnection,
    fetchPokemonFromDb,
    fetchTypeNameFromDb,
    fetchMoveIDFromDb,
    fetchAbilityIDFromDb,
    insertPokemon
};