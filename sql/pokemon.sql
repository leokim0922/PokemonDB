drop table ABILITY cascade constraints;
drop table APPEARSIN cascade constraints;
drop table BELONGS cascade constraints;
drop table EFFECT cascade constraints;
drop table EVOLVESINTO cascade constraints;
drop table GYM cascade constraints;
drop table ITEM_OWNS cascade constraints;
drop table ITEM_OWNS2 cascade constraints;
drop table LEARNS cascade constraints;
drop table LOCATION cascade constraints;
drop table MOVE_ASSOCIATES1 cascade constraints;
drop table MOVE_ASSOCIATES2 cascade constraints;
drop table OWNS cascade constraints;
drop table POKEMART cascade constraints;
drop table POKEMON cascade constraints;
drop table POSSESSES cascade constraints;
drop table REGION cascade constraints;
drop table SELLS cascade constraints;
drop table TRAINER_DEFENDS cascade constraints;
drop table TYPE cascade constraints;
drop PROCEDURE AddPokemonWithTypeAbilityLearns;

-- CREATE TABLE statements

	CREATE TABLE Pokemon (
		PokemonID INTEGER PRIMARY KEY,
		PokemonName VARCHAR2(15) UNIQUE,
		PokemonDescription VARCHAR2(200)
	);

	CREATE TABLE Type(
		TypeName VARCHAR2(15) PRIMARY KEY,
		TypeDescription VARCHAR2(200)
	);

	CREATE TABLE Effect(
		TypeName1 VARCHAR2(15),
		TypeName2 VARCHAR2(15),
		Percentage INTEGER,
		PRIMARY KEY (TypeName1, TypeName2),
		FOREIGN KEY (TypeName1) REFERENCES
			Type(TypeName)
			ON DELETE CASCADE,
		FOREIGN KEY (TypeName2) REFERENCES
			Type(TypeName)
			ON DELETE CASCADE
	);

	CREATE TABLE Belongs(
		PokemonID INTEGER,
		TypeName VARCHAR2(15),
		PRIMARY KEY (PokemonID, TypeName),
		FOREIGN KEY (PokemonID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE CASCADE,
		FOREIGN KEY (TypeName) REFERENCES
		Type(TypeName)
		ON DELETE CASCADE
	);

	CREATE TABLE Ability(
		AbilityID INTEGER PRIMARY KEY,
		AbilityEffect VARCHAR(100)
	);

	CREATE TABLE Possesses(
		PokemonID INTEGER,
		AbilityID INTEGER,
		PRIMARY KEY (PokemonID, AbilityID),
		FOREIGN KEY (PokemonID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE CASCADE,
		FOREIGN KEY (AbilityID) REFERENCES
		Ability(AbilityID)
		ON DELETE CASCADE
	);

	CREATE TABLE Move_Associates2 (
		MoveEffect VARCHAR2(200) PRIMARY KEY,
		TypeName VARCHAR2(15),
		FOREIGN KEY (TypeName) REFERENCES
		Type(TypeName)
		ON DELETE SET NULL
	);

	CREATE TABLE Move_Associates1 (
		MoveID INTEGER PRIMARY KEY,
		MoveName VARCHAR2(20) UNIQUE,
		Power INTEGER,
		Accuracy INTEGER,
		PowerPoints INTEGER,
		MoveEffect VARCHAR2(200),
		FOREIGN KEY (MoveEffect) REFERENCES
		Move_Associates2 (MoveEffect)
	);

	CREATE TABLE Learns (
		PokemonID INTEGER,
		MoveID INTEGER NOT NULL,
		PRIMARY KEY (PokemonID, MoveID),
		FOREIGN KEY (PokemonID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE CASCADE,
		FOREIGN KEY (MoveID) REFERENCES
		Move_Associates1(MoveID)
		ON DELETE CASCADE
	);

	CREATE TABLE EvolvesInto(
		PreEvolutionID INTEGER,
		PostEvolutionID INTEGER,
		Condition VARCHAR(200),
		PRIMARY KEY (PreEvolutionID, PostEvolutionID),
		FOREIGN KEY (PreEvolutionID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE CASCADE,
		FOREIGN KEY (PostEvolutionID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE CASCADE
	);

	CREATE TABLE Region(
		RegionName VARCHAR2(20) PRIMARY KEY,
		RegionDescription VARCHAR2(200)
	);

	CREATE TABLE Location(
		LocationName VARCHAR2(50),
		RegionName VARCHAR2(20),
		Function VARCHAR2(100),
		PRIMARY KEY (LocationName, RegionName),
		FOREIGN KEY (RegionName) REFERENCES
		Region(RegionName)
		ON DELETE CASCADE
	);

	CREATE TABLE AppearsIn(
		RegionName VARCHAR2(20),
		PokemonID INTEGER,
		PRIMARY KEY (RegionName, PokemonID),
		FOREIGN KEY (RegionName) REFERENCES
		Region(RegionName)
		ON DELETE CASCADE,
		FOREIGN KEY (PokemonID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE CASCADE
	);

	CREATE TABLE Gym(
		LocationName VARCHAR2(50),
		RegionName VARCHAR2(20),
		Badge VARCHAR2(30),
		PRIMARY KEY (LocationName, RegionName),
		FOREIGN KEY (LocationName, RegionName) REFERENCES
		Location(LocationName, RegionName)
		ON DELETE CASCADE
	);

	CREATE TABLE Trainer_Defends(
		TrainerName VARCHAR2(30) PRIMARY KEY,
		Winnings INTEGER,
		LocationName VARCHAR2(50),
		RegionName VARCHAR2(20),
		FOREIGN KEY (LocationName, RegionName) REFERENCES
		Gym(LocationName, RegionName)
		ON DELETE SET NULL
	);

	CREATE TABLE Owns (
		TrainerName VARCHAR2(30),
		PokemonID INTEGER,
		PRIMARY KEY (TrainerName, PokemonID),
		FOREIGN KEY (TrainerName) REFERENCES
		Trainer_Defends(TrainerName)
		ON DELETE CASCADE,
		FOREIGN KEY (PokemonID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE CASCADE
	);

	CREATE TABLE Pokemart(
		LocationName VARCHAR2(50),
		RegionName VARCHAR2(20),
		PRIMARY KEY (LocationName, RegionName),
		FOREIGN KEY (LocationName, RegionName) REFERENCES
		Location(LocationName, RegionName)
		ON DELETE CASCADE
	);

	CREATE TABLE Item_Owns2(
		ItemEffect VARCHAR2(200) PRIMARY KEY,
		ItemType VARCHAR2(50)
	);

	CREATE TABLE Item_Owns(
		ItemName VARCHAR2(30) PRIMARY KEY,
		ItemEffect VARCHAR2(200),
		PokemonID INTEGER,
		FOREIGN KEY (ItemEffect) REFERENCES
		Item_Owns2(ItemEffect)
		ON DELETE CASCADE,
		FOREIGN KEY (PokemonID) REFERENCES
		Pokemon(PokemonID)
		ON DELETE SET NULL
	);

	CREATE TABLE Sells(
		ItemName VARCHAR2(30) NOT NULL,
		LocationName VARCHAR2(50),
		RegionName VARCHAR2(20),
		PRIMARY KEY (ItemName, LocationName, RegionName),
		FOREIGN KEY (ItemName) REFERENCES
		Item_Owns(ItemName)
		ON DELETE CASCADE,
		FOREIGN KEY (LocationName, RegionName) REFERENCES
		Pokemart(LocationName, RegionName)
		ON DELETE CASCADE
	);

-- PROCEDURE STATEMENTS

	-- PROCEDURE to add Pokemon (Belongs) Associated Type 
	CREATE OR REPLACE PROCEDURE AddPokemonWithTypeAbilityLearns (
	p_PokemonID IN INTEGER,
	p_PokemonDescription IN VARCHAR2,
	p_PokemonName IN VARCHAR2,
	p_TypeName IN VARCHAR2,
	p_AbilityID IN INTEGER,
	p_MoveID IN INTEGER
	)
	IS
	v_TypeCount NUMBER;
	v_AbilityCount NUMBER;
	v_MoveCount NUMBER;
	BEGIN
	-- Check if Type exists
		SELECT COUNT(*)
		INTO v_TypeCount
		FROM Type
		WHERE TypeName = p_TypeName;

		IF v_TypeCount = 0 THEN
			RAISE_APPLICATION_ERROR(-20001, 'Error: Type does not exist.');
		END IF;

	-- Check if Ability exists
		SELECT COUNT(*)
		INTO v_AbilityCount
		FROM Ability
		WHERE AbilityID = p_AbilityID;

		IF v_AbilityCount = 0 THEN
			RAISE_APPLICATION_ERROR(-20002, 'Error: Ability does not exist.');
		END IF;

	-- Check if Move exists
		SELECT COUNT(*)
		INTO v_MoveCount
		FROM Move_Associates1
		WHERE MoveID = p_MoveID;

		IF v_MoveCount = 0 THEN
			RAISE_APPLICATION_ERROR(-20003, 'Error: Move does not exist.');
		END IF;


	-- Insert into Pokemon
	INSERT INTO Pokemon
	VALUES (p_PokemonID, p_PokemonName, p_PokemonDescription);
	
	-- Insert into Belongs
	INSERT INTO Belongs
	VALUES (p_PokemonID, p_TypeName);

	-- Insert into Possesses
	INSERT INTO Possesses
	VALUES (p_PokemonID, p_AbilityID);

	-- Insert into Learns
	INSERT INTO Learns
	VALUES (p_PokemonID, p_MoveID);

	COMMIT;
	DBMS_OUTPUT.PUT_LINE('Pokemon, Belongs, Possesses, Learns inserted successfully.');
	EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
	END;
	/

-- INSERT STATEMENTS:

	-- INSERT Ability
		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (201, 'Overgrow - Boosts Grass moves in a pinch');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (202, 'Blaze - Boosts Fire moves in a pinch');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (203, 'Torrent - Boosts Water moves in a pinch');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (204, 'Static - May cause paralysis upon contact');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (205, 'Levitate - Immune to Ground-type moves');

	-- INSERT Types
		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Fire', 'Fire is one of the three basic elemental types along with Water and
		Grass');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Water', 'Water is one of the three basic elemental types along with Fire and
		Grass');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Grass', 'Grass is one of the three basic elemental types along with Fire and
		Water');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Electric', 'Electric Pokemon are very good defensively, being weak only to
		Ground moves.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Psychic', 'The Psychic type has few outright strengths, however, it also has few
		weaknesses.');

	-- INSERT Move_Associates
		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Burns opponent', 'Fire');

		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints,
		MoveEffect)
		VALUES (101, 'Flamethrower', 90, 100, 15, 'Burns opponent');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('High power water attack', 'Water');

		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints,
		MoveEffect)
		VALUES (102, 'Hydro Pump', 110, 80, 5, 'High power water attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Charges and fires on second turn', 'Grass');

		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints,
		MoveEffect)
		VALUES (103, 'Solar Beam', 120, 100, 10, 'Charges and fires on second turn');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('May paralyze opponent', 'Electric');

		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints,
		MoveEffect)
		VALUES (104, 'Thunderbolt', 90, 100, 15, 'May paralyze opponent');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('May lower opponent special defense', 'Psychic');
		
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints,
		MoveEffect)
		VALUES (105, 'Psychic', 90, 100, 10, 'May lower opponent special defense');

	-- INSERT POKEMON with Associated Type & Ability & Learns
		BEGIN
			AddPokemonWithTypeAbilityLearns(101, 'An electric mouse', 'Pikachu', 'Electric', 204, 104);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(1, 'For some time after its birth, it uses the nutrients that are packed into the
			seed on its back in order to grow.', 'Bulbasaur', 'Grass', 201, 103);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(2, 'Its plant blooms when it is absorbing solar energy. It stays on the move to
			seek sunlight.', 'Ivysaur', 'Grass', 201, 103);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(3, 'Venusaur is a large, quadrupedal Pokemon with a turquoise body.',
			'Venusaur', 'Grass', 201, 103);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(4, 'It has a preference for hot things. When it rains, steam is said to spout from
			the tip of its tail.', 'Charmander', 'Fire', 202, 101);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(5, 'When it swings its burning tail, it elevates the temperature to unbearably high
			levels.', 'Charmeleon', 'Fire', 202, 101);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(6, 'Spits fire that is hot enough to melt boulders. Known to cause forest fires
			unintentionally.', 'Charizard', 'Fire', 202, 101);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(7, 'When its huge eyes light up, it leans forward and rams into its foe at full
			speed.', 'Squirtle', 'Water', 203, 102);
		END;
		/

	-- INSERT Effect
		INSERT
		INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fire', 'Water', 50);

		INSERT
		INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fire', 'Electric', 50);

		INSERT
		INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fire', 'Fire', 50);

		INSERT
		INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Grass', 'Water', 200);

		INSERT
		INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Water', 'Fire', 200);

	-- INSERT EvolvesInto
		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (1, 2, 'Level 16');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (2, 3, 'Level 40');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (4, 5, 'Level 17');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (5, 6, 'Level 38');

	-- INSERT Region
		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Kanto', 'The first region in the Pokemon world, home to 151 species.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Johto', 'A neighboring region with legendary Pokemon.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Hoenn', 'A tropical region with diverse Pokemon species.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Sinnoh', 'A cold northern region with ancient legends.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Unova', 'A modernized region with industrial cities.');

	-- INSERT AppearsIn
		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 1);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 2);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 3);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 4);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 5);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 6);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 7);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Hoenn', 101);

	-- INSERT Location
		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Pewter City', 'Kanto', 'Gym, Pokemart, Museum');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Cerulean City', 'Kanto', 'Gym, Pokemart, Bike Shop');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Vermilion City', 'Kanto', 'Pokemart, Gym');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Blackthorn City', 'Johto', 'Pokemart, Gym');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Violet City', 'Johto', 'Gym');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Azalea Town', 'Johto', 'Gym');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Goldenrod Radio Tower', 'Johto', 'Broadcast radio programs across the Johto Region');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Mt. Pyre', 'Hoenn', 'A Pokemon graveyard');

	-- INSERT Gym
		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Pewter City', 'Kanto', 'Boulder Badge');

		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Cerulean City', 'Kanto', 'Cascade Badge');

		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Vermilion City', 'Kanto', 'Thunder Badge');

		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Violet City', 'Johto', 'Zephyr Badge');

		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Azalea Town', 'Johto', 'Hive Badge');

	-- INSERT Trainer_Defends
		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Brock', 500, 'Pewter City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Camper Liam', 220, 'Pewter City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Misty', 600, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Lt. Surge', 700, 'Vermilion City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Falkner', 710, 'Violet City', 'Johto');

	-- INSERT Owns
		INSERT INTO Owns(TrainerName, PokemonID)
		VALUES ('Camper Liam', 1);

		INSERT INTO Owns(TrainerName, PokemonID)
		VALUES ('Falkner', 3);

		INSERT INTO Owns(TrainerName, PokemonID)
		VALUES ('Misty', 3);

		INSERT INTO Owns(TrainerName, PokemonID)
		VALUES ('Brock', 4);

		INSERT INTO Owns(TrainerName, PokemonID)
		VALUES ('Lt. Surge', 5);
			
		INSERT INTO Owns(TrainerName, PokemonID)
		VALUES ('Lt. Surge', 2);

	-- INSERT Pokemart
		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Pewter City', 'Kanto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Cerulean City', 'Kanto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Azalea Town', 'Johto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Blackthorn City', 'Johto');
		
	-- INSERT Item_Owns
		INSERT INTO Item_Owns2
		VALUES ('Restores 20 HP', 'Healing');

		INSERT INTO Item_Owns
		VALUES ('Potion', 'Restores 20 HP', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Restores 50 HP', 'Healing');

		INSERT INTO Item_Owns
		VALUES ('Super Potion', 'Restores 50 HP', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Restores 100 HP', 'Healing');

		INSERT INTO Item_Owns
		VALUES ('Hyper Potion', 'Restores 100 HP', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Evolves Fire-type Pokemon', 'Evolution');

		INSERT INTO Item_Owns
		VALUES('Fire Stone', 'Evolves Fire-type Pokemon', 2);

		INSERT INTO Item_Owns2
		VALUES ('Evolves Water-type Pokemon', 'Evolution');

		INSERT INTO Item_Owns
		VALUES ('Water Stone', 'Evolves Water-type Pokemon', 3);

		INSERT INTO Item_Owns2
		VALUES ('Increases level by one', 'Stat');

		INSERT INTO Item_Owns
		VALUES ('Rare Candy', 'Increases level by one', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Wakes up a sleeping pokemon', 'Medicine');

		INSERT INTO Item_Owns
		VALUES ('Awakening', 'Wakes up a sleeping pokemon', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Captures Pokemon', 'Pokeball');

		INSERT INTO Item_Owns
		VALUES ('Poke Ball', 'Captures Pokemon', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Better Captures Pokemon', 'Pokeball');

		INSERT INTO Item_Owns
		VALUES ('Great Ball', 'Better Captures Pokemon', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Greatly Captures Pokemon', 'Pokeball');

		INSERT INTO Item_Owns
		VALUES ('Ultra Ball', 'Greatly Captures Pokemon', NULL);

	-- INSERT Sells
		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Potion', 'Pewter City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Potion', 'Cerulean City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Super Potion', 'Cerulean City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Potion', 'Blackthorn City', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Super Potion', 'Blackthorn City', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Hyper Potion', 'Blackthorn City', 'Johto');
		
		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Poke Ball', 'Pewter City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Great Ball', 'Pewter City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Ultra Ball', 'Cerulean City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Water Stone', 'Cerulean City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Fire Stone', 'Cerulean City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Rare Candy', 'Blackthorn City', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Awakening', 'Blackthorn City', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Poke Ball', 'Azalea Town', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Great Ball', 'Azalea Town', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Fire Stone', 'Azalea Town', 'Johto');

COMMIT;