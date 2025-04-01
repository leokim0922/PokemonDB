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
    const query = 'SELECT abilityid FROM ability';
    return await fetchQuery(query);
}

// SELECT FROM DATABASE
async function fetchPokemonIDFromDb() {
    const query = 'SELECT pokemonid FROM Pokemon';
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
        query += ' AND t.Typename = :type';
        bindValues.type = type;
    }
    if (op1 !== 'None' && num1 >= 0) {
        if (!['=', '!=', '<', '<=', '>', '>='].includes(op1)) {
            throw new Error(`Invalid operator: ${op1}`);
        }
        query += ` AND (e.percentage ${op1} :num1`;
        bindValues.num1 = num1;

        if (logic !== 'None') {
            if (!['AND', 'OR'].includes(logic)) {
                throw new Error(`Invalid logical operator: ${logic}`);
            }
            if (op2 !== 'None' && num2 >= 0) {
                if (!['=', '!=', '<', '<=', '>', '>='].includes(op2)) {
                    throw new Error(`Invalid operator: ${op2}`);
                }
                query += ` ${logic} e.percentage ${op2} :num2`;
                bindValues.num2 = num2;
            }
        }
        query += ')';
    }

    console.log("Final Query: ", query);
    console.log("Bind Values: ", bindValues);

    try {
        return await fetchQuery(query, bindValues);
    } catch (error) {
        console.error("Error executing query:", error.message);
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
    fetchTypesEffectParamsFromDb
};