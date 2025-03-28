drop table ABILITY cascade constraints;
drop table APPEARSIN cascade constraints;
drop table BELONGS cascade constraints;
drop table EFFECT cascade constraints;
drop table EVOLVESINTO cascade constraints;
drop table GYM cascade constraints;
drop table ITEM_OWNS cascade constraints;
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

	CREATE TABLE Item_Owns(
		ItemName VARCHAR2(30) PRIMARY KEY,
		ItemEffect VARCHAR2(200),
		ItemType VARCHAR2(50),
		PokemonID INTEGER,
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
	VALUES (p_PokemonID, p_PokemonDescription, p_PokemonName);
	
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
