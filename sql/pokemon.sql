drop VIEW moveType cascade constraints;
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

	CREATE VIEW MoveType(moveid, movename, power, accuracy, powerpoints, moveeffect, typename) AS
		SELECT m1.MoveID, m1.MoveName, m1.Power, m1.Accuracy, m1.PowerPoints, m1.MoveEffect,
		m2.TypeName 
		FROM Move_Associates1 m1, Move_Associates2 m2
		WHERE m1.MoveEffect = m2.MoveEffect;
		
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

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (1, 'Stench - By releasing a stench when attacking, the Pokemon may cause the target to flinch. ');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (2, 'Drizzle -  	The Pokemon makes it rain when it enters a battle. ');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (3, 'Speed Boost - The Pokemons Speed stat is boosted every turn.');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (4, 'Battle Armor -  Hard armor protects the Pokemon from critical hits. ');

		INSERT
		INTO Ability(AbilityID, AbilityEffect)
		VALUES (5, 'Sturdy -The Pokemon cannot be knocked out by a single hit as long as its HP is full.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (6, 'Damp - Prevents all Pokemon from using explosive moves like Self-Destruct.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (7, 'Limber - Prevents the Pokemon from being paralyzed.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (8, 'Sand Veil - Boosts the Pokemons evasiveness in a sandstorm.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (9, 'Static - May paralyze attackers that make direct contact with the Pokemon.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (10, 'Volt Absorb - Restores HP instead of taking damage from Electric-type moves.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (11, 'Water Absorb - Restores HP instead of taking damage from Water-type moves.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (12, 'Oblivious - Prevents infatuation, taunts, and the effects of Intimidate.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (13, 'Cloud Nine - Eliminates the effects of weather.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (14, 'Compound Eyes - Increases the Pokemons accuracy.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (15, 'Insomnia - Prevents the Pokemon from falling asleep.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (16, 'Color Change - The Pokemons type changes to match the move used on it.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (17, 'Immunity - Prevents the Pokemon from being poisoned.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (18, 'Flash Fire - Powers up Fire-type moves when hit by one.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (19, 'Shield Dust - Blocks additional effects of incoming moves.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (20, 'Own Tempo - Prevents confusion and the effects of Intimidate.');

		COMMIT;

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (21, 'Suction Cups - Prevents forced switching due to moves or items.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (22, 'Intimidate - Lowers the Attack of opposing Pokemon when entering battle.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (23, 'Shadow Tag - Prevents opposing Pokemon from switching out or escaping.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (24, 'Rough Skin - Damages attackers that make direct contact.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (25, 'Wonder Guard - Only supereffective moves can hit this Pokemon.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (26, 'Levitate - Grants full immunity to all Ground-type moves.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (27, 'Effect Spore - Contact may inflict poison, sleep, or paralysis.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (28, 'Synchronize - Passes on burn, paralysis, or poison to the foe.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (29, 'Clear Body - Prevents stat reduction from opposing Pokemon.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (30, 'Natural Cure - Heals status conditions when switching out.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (31, 'Lightning Rod - Draws in Electric moves and boosts Sp. Atk instead.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (32, 'Serene Grace - Boosts the chance of additional move effects occurring.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (33, 'Swift Swim - Increases Speed during rain.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (34, 'Chlorophyll - Increases Speed in harsh sunlight.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (35, 'Illuminate - Prevents accuracy from being lowered.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (36, 'Trace - Copies an opposing Pokemons Ability when entering battle.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (37, 'Huge Power - Doubles the Pokemons Attack stat.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (38, 'Poison Point - May poison attackers that make direct contact.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (39, 'Inner Focus - Prevents flinching and the effects of Intimidate.');

		INSERT INTO Ability (AbilityID, AbilityEffect)
		VALUES (40, 'Magma Armor - Prevents the Pokemon from being frozen.');

		COMMIT;

	-- INSERT Types
		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Normal', 'Normal-type moves have no special effectiveness or weaknesses.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Fire', 'Fire-type moves are strong against Grass, Bug, Ice, and Steel, but weak against Water, Rock, and Fire.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Water', 'Water-type moves are strong against Fire, Rock, and Ground, but weak against Water, Grass, and Electric.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Grass', 'Grass-type moves are strong against Water, Ground, and Rock, but weak against Fire, Poison, Flying, Bug, and Grass.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Electric', 'Electric-type moves are strong against Water and Flying, but weak against Electric, Ground, and Grass.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Ice', 'Ice-type moves are strong against Dragon, Flying, Grass, and Ground, but weak against Fire, Ice, Steel, and Water.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Fighting', 'Fighting-type moves are strong against Normal, Ice, Rock, Dark, and Steel, but weak against Flying, Psychic, Bug, Fairy, and Poison.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Poison', 'Poison-type moves are strong against Grass and Fairy, but weak against Poison, Ground, Rock, and Ghost.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Ground', 'Ground-type moves are strong against Fire, Electric, Poison, Rock, and Steel, but weak against Grass and Bug.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Flying', 'Flying-type moves are strong against Grass, Fighting, and Bug, but weak against Electric, Ice, and Rock.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Psychic', 'Psychic-type moves are strong against Fighting and Poison, but weak against Psychic and Steel.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Bug', 'Bug-type moves are strong against Grass, Psychic, and Dark, but weak against Fire, Fighting, Poison, Flying, Ghost, Steel, and Fairy.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Rock', 'Rock-type moves are strong against Fire, Ice, Flying, and Bug, but weak against Fighting, Ground, and Steel.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Ghost', 'Ghost-type moves are strong against Psychic and Ghost, but weak against Dark.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Dragon', 'Dragon-type moves are strong against Dragon, but weak against Steel and Fairy.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Dark', 'Dark-type moves are strong against Psychic and Ghost, but weak against Fighting, Fairy, and Bug.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Steel', 'Steel-type moves are strong against Ice, Rock, and Fairy, but weak against Fire, Water, and Electric.');

		INSERT
		INTO Type(TypeName, TypeDescription)
		VALUES ('Fairy', 'Fairy-type moves are strong against Fighting, Dragon, and Dark, but weak against Poison, Steel, and Fire.');

		COMMIT;

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

		COMMIT;

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Pound attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (1, 'Pound', 40, 100, 35, 'Normal Pound attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Fighting Chop attack', 'Fighting');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (2, 'Karate Chop', 50, 100, 25, 'Fighting Chop attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack, may hit twice', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (3, 'Double Slap', 15, 85, 10, 'Normal physical attack, may hit twice');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack, may hit multiple times', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (4, 'Comet Punch', 18, 85, 15, 'Normal physical attack, may hit multiple times');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Mega physical attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (5, 'Mega Punch', 80, 85, 20, 'Normal Mega physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal move that earns money', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (6, 'Pay Day', 40, 100, 20, 'Normal move that earns money');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Fire physical attack', 'Fire');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (7, 'Fire Punch', 75, 100, 15, 'Fire physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Ice physical attack', 'Ice');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (8, 'Ice Punch', 75, 100, 15, 'Ice physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Electric physical attack', 'Electric');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (9, 'Thunder Punch', 75, 100, 15, 'Electric physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Scratch attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (10, 'Scratch', 40, 100, 35, 'Normal Scratch attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Grip attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (11, 'Vise Grip', 55, 100, 30, 'Normal Grip attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Instant KO move with low accuracy', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (12, 'Guillotine', 1000, 30, 5, 'Instant KO move with low accuracy');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal move that charges and strikes next turn', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (13, 'Razor Wind', 80, 100, 10, 'Normal move that charges and strikes next turn');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal move to raise attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (14, 'Swords Dance', 0, 0, 20, 'Normal move to raise attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Cut attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (15, 'Cut', 50, 95, 30, 'Normal Cut attack');

		COMMIT;

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Flying Gust attack', 'Flying');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (16, 'Gust', 40, 100, 35, 'Flying Gust attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Flying Wing attack', 'Flying');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (17, 'Wing Attack', 60, 100, 35, 'Flying Wing attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal move that causes opponent to flee', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (18, 'Whirlwind', 0, 1000, 20, 'Normal move that causes opponent to flee');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Flying physical attack', 'Flying');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (19, 'Fly', 90, 95, 15, 'Flying physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal move that traps the opponent', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (20, 'Bind', 15, 85, 20, 'Normal move that traps the opponent');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Slam attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (21, 'Slam', 80, 75, 20, 'Normal Slam attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Grass physical attack', 'Grass');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (22, 'Vine Whip', 45, 100, 25, 'Grass physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Stomp attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (23, 'Stomp', 65, 100, 20, 'Normal Stomp attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Fighting Kick attack', 'Fighting');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (24, 'Double Kick', 30, 100, 30, 'Fighting Kick attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack with low accuracy', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (25, 'Mega Kick', 120, 75, 5, 'Normal physical attack with low accuracy');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Fighting physical attack with high power', 'Fighting');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (26, 'Jump Kick', 100, 95, 10, 'Fighting physical attack with high power');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Fighting physical attack with moderate power', 'Fighting');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (27, 'Rolling Kick', 60, 85, 15, 'Fighting physical attack with moderate power');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Ground move that reduces accuracy', 'Ground');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (28, 'Sand Attack', 0, 100, 15, 'Ground move that reduces accuracy');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack with flinching', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (29, 'Headbutt', 70, 100, 15, 'Normal physical attack with flinching');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal Horn attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (30, 'Horn Attack', 65, 100, 25, 'Normal Horn attack');

		COMMIT;

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Drenches opponent in water, may lower speed', 'Water');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (31, 'Aqua Surge', 85, 95, 10, 'Drenches opponent in water, may lower speed');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Powerful water blast that takes time to charge', 'Water');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (32, 'Tsunami Wave', 120, 80, 5, 'Powerful water blast that takes time to charge');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Rapid water jets strike multiple times', 'Water');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (33, 'Hydro Barrage', 30, 100, 15, 'Rapid water jets strike multiple times');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Steel claw attack, may increase user attack', 'Steel');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (34, 'Iron Slash', 70, 100, 20, 'Steel claw attack, may increase user attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Steel punch with high impact', 'Steel');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (35, 'Titan Fist', 90, 95, 10, 'Steel punch with high impact');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Sharp metallic shards strike multiple times', 'Steel');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (36, 'Steel Shrapnel', 25, 100, 20, 'Sharp metallic shards strike multiple times');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Rock smash attack, may lower opponent defense', 'Rock');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (37, 'Boulder Crash', 80, 90, 15, 'Rock smash attack, may lower opponent defense');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Heavy rock slam attack', 'Rock');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (38, 'Stone Slam', 100, 85, 10, 'Heavy rock slam attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Scattering sharp rocks to damage opponent', 'Rock');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (39, 'Rock Shards', 50, 100, 20, 'Scattering sharp rocks to damage opponent');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Psychic force pushes opponent away', 'Psychic');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (40, 'Mind Thrust', 75, 100, 15, 'Psychic force pushes opponent away');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Strong psychic blast that may lower special defense', 'Psychic');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (41, 'Psi Storm', 95, 90, 10, 'Strong psychic blast that may lower special defense');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Manipulates gravity to increase damage on next turn', 'Psychic');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (42, 'Gravity Crush', 0, 0, 15, 'Manipulates gravity to increase damage on next turn');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Toxic mist engulfs opponent', 'Poison');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (43, 'Venom Fog', 60, 100, 15, 'Toxic mist engulfs opponent');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Poisonous fangs that may badly poison', 'Poison');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (44, 'Toxic Bite', 80, 95, 10, 'Poisonous fangs that may badly poison');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Freezing blast with a chance to freeze', 'Ice');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (45, 'Glacier Beam', 90, 95, 10, 'Freezing blast with a chance to freeze');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Ground shaking attack that may cause flinching', 'Ground');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (46, 'Tectonic Slam', 110, 80, 5, 'Ground shaking attack that may cause flinching');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Haunting attack that may cause confusion', 'Ghost');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (47, 'Phantom Howl', 75, 95, 15, 'Haunting attack that may cause confusion');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Ethereal strike bypasses defenses', 'Ghost');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (48, 'Spectral Slash', 90, 100, 10, 'Ethereal strike bypasses defenses');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Dark tendrils strike opponent', 'Dark');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (49, 'Night Bind', 80, 95, 15, 'Dark tendrils strike opponent');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Mystical fairy blast', 'Fairy');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (50, 'Pixie Burst', 85, 100, 10, 'Mystical fairy blast');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Swarm of insects bite opponent', 'Bug');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (51, 'Insect Swarm', 60, 100, 15, 'Swarm of insects bite opponent');

		COMMIT;

	-- INSERT POKEMON with Associated Type & Ability & Learns
		BEGIN
			AddPokemonWithTypeAbilityLearns(1, 'A grass-poison type Pokemon that grows flowers as it evolves. Known for its sweet scent.', 'Bulbasaur', 'Grass', 201, 101);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(2, 'It evolves from Bulbasaur. The seed on its back grows into a large plant as it matures.', 'Ivysaur', 'Grass', 202, 102);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(3, 'Known for its powerful solar beam attack. It is fully grown with an enormous plant on its back.', 'Venusaur', 'Grass', 203, 103);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(4, 'A fire-type Pokemon that burns with great intensity, often using its flame to intimidate opponents.', 'Charmander', 'Fire', 204, 104);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(5, 'It evolves from Charmander and is known for its fiery tail flame that burns fiercely.', 'Charmeleon', 'Fire', 205, 105);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(6, 'Spits fire that is hot enough to melt boulders. Known to cause forest fires unintentionally.', 'Charizard', 'Fire', 202, 101);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(7, 'When its huge eyes light up, it leans forward and rams into its foe at full speed.', 'Squirtle', 'Water', 203, 102);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(8, 'It evolves from Squirtle and uses its powerful tail to swim at high speeds.', 'Wartortle', 'Water', 204, 103);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(9, 'A mighty and fearsome Pokemon with a tough shell, it is a master of water-based attacks.', 'Blastoise', 'Water', 205, 104);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(10, 'It is a bug-type Pokemon with a soft, green body, known for its adorable appearance and simple nature.', 'Caterpie', 'Bug', 1, 24);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(11, 'It evolves from Caterpie and forms a cocoon to undergo its metamorphosis.', 'Metapod', 'Bug', 2, 30);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(12, 'A graceful butterfly Pokemon with beautiful wings, it uses powders for defense.', 'Butterfree', 'Bug', 12, 23);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(13, 'Known for its quick and agile flying abilities, it is a normal and flying-type Pokemon.', 'Pidgey', 'Normal', 30, 21);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(14, 'It evolves from Pidgey and is skilled at aerial combat, using powerful wing attacks.', 'Pidgeotto', 'Normal', 32, 30);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(15, 'A powerful and majestic bird known for its speed and aerial acrobatics.', 'Pidgeot', 'Normal', 11, 11);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(16, 'It is a normal-type Pokemon with a fast-moving and agile nature, known for its quick attacks.', 'Rattata', 'Normal', 12, 11);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(17, 'A tougher and stronger version of Rattata, it is adept at using its teeth and claws in battle.', 'Raticate', 'Normal', 6, 9);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(18, 'It is a snake-like Pokemon that specializes in stealthy movements and venomous attacks.', 'Ekans', 'Poison', 3, 24);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(19, 'It evolves from Ekans and has a fearsome presence with powerful poison-based attacks.', 'Arbok', 'Poison', 12, 16);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(20, 'A dog-like Pokemon with a friendly demeanor, it is known for its fire-based attacks and loyal nature.', 'Growlithe', 'Fire', 18, 23);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(21, 'It evolves from Growlithe and is a fierce and loyal guardian of its territory.', 'Arcanine', 'Fire', 4, 30);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(22, 'It is a tadpole Pokemon with powerful water abilities and a distinctive spiral pattern.', 'Poliwag', 'Water', 5, 7);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(23, 'It evolves from Poliwag and is skilled in both water and fighting moves.', 'Poliwhirl', 'Water', 8, 28);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(24, 'A massive turtle-like Pokemon that controls water and is equipped with powerful attacks.', 'Politoed', 'Water', 6, 30);
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

		COMMIT;

		-- Normal Type against other Types
		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Normal', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Fighting', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Flying', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Poison', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Ground', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Rock', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Bug', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Ghost', 0);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Steel', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Fire', 50);

		COMMIT;

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Water', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Grass', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Electric', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Psychic', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Ice', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Dragon', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Dark', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Normal', 'Fairy', 100);

		COMMIT;

		-- Fighting Type against other Types
		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Normal', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Fighting', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Flying', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Poison', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Ground', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Rock', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Bug', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Ghost', 0);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Steel', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Fire', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Water', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Grass', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Electric', 100);

		COMMIT;

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Psychic', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Ice', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Dragon', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Dark', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Fighting', 'Fairy', 50);

		COMMIT;

		-- Flying Type against other Types
		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Normal', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Fighting', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Flying', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Poison', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Ground', 0);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Rock', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Bug', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Ghost', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Steel', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Fire', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Water', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Grass', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Electric', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Psychic', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Ice', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Dragon', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Dark', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Flying', 'Fairy', 100);

		COMMIT;

		-- Poison Type against other Types
		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Normal', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Fighting', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Flying', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Poison', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Ground', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Rock', 50);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Bug', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Ghost', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Steel', 0);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Fire', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Water', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Grass', 200);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Electric', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Psychic', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Ice', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Dragon', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Dark', 100);

		INSERT INTO Effect(TypeName1, TypeName2, Percentage)
		VALUES ('Poison', 'Fairy', 200);

		COMMIT;

		-- Bug Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Bug', 'Grass', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Bug', 'Psychic', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Bug', 'Fighting', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Bug', 'Fire', 50);

		-- Dark Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dark', 'Psychic', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dark', 'Fighting', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dark', 'Fairy', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dark', 'Ghost', 200);

		-- Dragon Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dragon', 'Dragon', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dragon', 'Fairy', 0);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dragon', 'Ice', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Dragon', 'Steel', 50);

		-- Electric Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Electric', 'Water', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Electric', 'Ground', 0);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Electric', 'Flying', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Electric', 'Grass', 50);

		-- Water Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Water', 'Fire', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Water', 'Rock', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Water', 'Grass', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Water', 'Dragon', 50);

		-- Steel Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Steel', 'Ice', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Steel', 'Rock', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Steel', 'Water', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Steel', 'Electric', 50);

		-- Rock Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Rock', 'Fire', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Rock', 'Flying', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Rock', 'Fighting', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Rock', 'Steel', 50);

		COMMIT;

		-- Psychic Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Psychic', 'Fighting', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Psychic', 'Poison', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Psychic', 'Steel', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Psychic', 'Dark', 0);

		-- Ground Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ground', 'Electric', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ground', 'Flying', 0);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ground', 'Rock', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ground', 'Bug', 50);

		-- Ice Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ice', 'Dragon', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ice', 'Flying', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ice', 'Water', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ice', 'Fire', 50);

		-- Grass Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Grass', 'Water', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Grass', 'Ground', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Grass', 'Flying', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Grass', 'Steel', 50);

		-- Ghost Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ghost', 'Ghost', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ghost', 'Psychic', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ghost', 'Normal', 0);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Ghost', 'Dark', 50);

		-- Fairy Type Effectiveness
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Fairy', 'Dragon', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Fairy', 'Dark', 200);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Fairy', 'Fire', 50);
		INSERT INTO Effect(TypeName1, TypeName2, Percentage) VALUES ('Fairy', 'Poison', 50);

		COMMIT;

	-- INSERT EvolvesInto
		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (1, 2, 'Level 16'); 

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (2, 3, 'Level 32'); 

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (4, 5, 'Level 16'); 

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (5, 6, 'Level 36'); 

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (7, 8, 'Level 16'); 

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (8, 9, 'Level 36');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (10, 11, 'Level 20');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (11, 12, 'Level 30');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (13, 14, 'Level 16');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (14, 15, 'Level 36');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (16, 17, 'Level 16');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (18, 19, 'Level 20');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (20, 21, 'Use Fire Stone');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (22, 23, 'Use Water Stone');

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (23, 24, 'Use Water Stone');

		COMMIT;

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

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Galar', 'A region influenced by British culture, known for its new Pokemon League format.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Alola', 'A sun-soaked region inspired by Hawaii, with unique regional forms of Pokemon.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Kalos', 'A region inspired by France, known for its fashion, beauty, and artistic culture.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Orre', 'A desert-like region with a focus on shadow Pokemon and the battle against evil forces.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Fiore', 'A peaceful region with a strong bond between Pokemon and humans, known for its beauty.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Almia', 'A region with a great relationship between people and Pokemon, known for the Ranger organization.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Ransei', 'A region where warriors fight alongside Pokemon in a battle for control of territories.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Oblivia', 'A region where Pokemon Rangers help protect the land, with a focus on adventure and teamwork.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Decolore', 'A small region with numerous islands, and a unique history of mystical occurrences.');

		INSERT INTO Region(RegionName, RegionDescription)
		VALUES ('Sevii Islands', 'A group of islands off the Kanto region, with their own unique culture and history.');

		COMMIT;

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
		VALUES ('Hoenn', 6);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Unova', 16);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Galar', 18);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Galar', 20);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kalos', 14);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 9);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Alola', 10);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Alola', 22);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kalos', 15);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Galar', 2);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kanto', 12);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Johto', 11);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Unova', 8);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Sinnoh', 7);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Johto', 24);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Johto', 6);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Unova', 21);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Galar', 23);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Galar', 17);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Unova', 19);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Alola', 3);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Johto', 5);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Alola', 13);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Kalos', 4);

		INSERT INTO AppearsIn(RegionName, PokemonID)
		VALUES ('Sinnoh', 1);

		COMMIT; 

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

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Littleroot Town', 'Hoenn', 'Pokemart, Lab');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Slateport City', 'Hoenn', 'Pokemart, Harbor, Market');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Fortree City', 'Hoenn', 'Gym, Pokemart, Forest');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Mauville City', 'Hoenn', 'Gym, Pokemart, Game Corner');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Lilycove City', 'Hoenn', 'Gym, Pokemart, Museum');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Lumiose City', 'Kalos', 'Gym, Pokemart, Cafe');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Santalune City', 'Kalos', 'Gym, Pokemart, Forest');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Anistar City', 'Kalos', 'Gym, Pokemart, Sundial');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Virbank City', 'Unova', 'Gym, Pokemart, Film Studio');

		INSERT INTO Location(LocationName, RegionName, Function)
		VALUES ('Castelia City', 'Unova', 'Gym, Pokemart, Business District');

		COMMIT;

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

		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Slateport City', 'Hoenn', 'Sea Badge');

		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Fortree City', 'Hoenn', 'Feather Badge');

		INSERT INTO Gym(LocationName, RegionName, Badge)
		VALUES ('Lilycove City', 'Hoenn', 'Rain Badge');

		COMMIT;

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

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Swimmer Paula', 250, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Youngster Benny', 170, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Swimmer Mike', 200, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Mista', 800, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Youngster Joe', 150, 'Violet City', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Bird Keeper Andy', 220, 'Violet City', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Bird Keeper Steven', 300, 'Violet City', 'Johto');

		COMMIT;

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Falkna', 600, 'Violet City', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Bugsy', 500, 'Azalea Town', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Bug Catcher Rick', 150, 'Azalea Town', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Bug Catcher Tim', 130, 'Azalea Town', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Youngster Sam', 100, 'Azalea Town', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Steven Stone', 800, 'Slateport City', 'Hoenn');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Sailor John', 220, 'Slateport City', 'Hoenn');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Youngster Ben', 180, 'Slateport City', 'Hoenn');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Swimmer Kate', 250, 'Slateport City', 'Hoenn');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Hiker Tom', 450, 'Pewter City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Camper Jake', 300, 'Pewter City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Fisherman Kyle', 270, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName)
		VALUES ('Picnicker Sarah', 290, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Swimmer Julia', 230, 'Cerulean City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Gentleman Roger', 750, 'Vermilion City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Engineer Greg', 670, 'Vermilion City', 'Kanto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Bird Keeper Kevin', 280, 'Violet City', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Lass Megan', 200, 'Violet City', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Bug Catcher Leo', 160, 'Azalea Town', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Twins Emma', 140, 'Azalea Town', 'Johto');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Fisherman Joe', 190, 'Slateport City', 'Hoenn');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Tuber Tommy', 160, 'Slateport City', 'Hoenn');

		INSERT INTO Trainer_Defends(TrainerName, Winnings, LocationName, RegionName) 
		VALUES ('Sailor Mark', 240, 'Slateport City', 'Hoenn');

		COMMIT;

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

		COMMIT;

	-- INSERT Pokemart
		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Pewter City', 'Kanto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Cerulean City', 'Kanto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Azalea Town', 'Johto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Blackthorn City', 'Johto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Vermilion City', 'Kanto');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Mauville City', 'Hoenn');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Slateport City', 'Hoenn');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Fortree City', 'Hoenn');

		INSERT INTO Pokemart(LocationName, RegionName)
		VALUES ('Lilycove City', 'Hoenn');

		COMMIT;
		
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

		COMMIT;

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

		INSERT INTO Item_Owns2
		VALUES ('Restores 200 HP', 'Healing');

		INSERT INTO Item_Owns
		VALUES ('Max Potion', 'Restores 200 HP', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Evolves Electric-type Pokemon', 'Evolution');

		INSERT INTO Item_Owns
		VALUES ('Thunder Stone', 'Evolves Electric-type Pokemon', 4);

		INSERT INTO Item_Owns2
		VALUES ('Evolves Leaf-type Pokemon', 'Evolution');

		INSERT INTO Item_Owns
		VALUES ('Leaf Stone', 'Evolves Leaf-type Pokemon', 5);

		INSERT INTO Item_Owns2
		VALUES ('Restores 50 PP', 'Medicine');

		INSERT INTO Item_Owns
		VALUES ('Ether', 'Restores 50 PP', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Restores 100 PP', 'Medicine');

		INSERT INTO Item_Owns
		VALUES ('Max Ether', 'Restores 100 PP', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Cures Poison', 'Medicine');

		INSERT INTO Item_Owns
		VALUES ('Antidote', 'Cures Poison', NULL);

		COMMIT;

		INSERT INTO Item_Owns2
		VALUES ('Increases Defense Stat', 'Stat');

		INSERT INTO Item_Owns
		VALUES ('Iron', 'Increases Defense Stat', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Increases Speed Stat', 'Stat');

		INSERT INTO Item_Owns
		VALUES ('Carbos', 'Increases Speed Stat', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Increases Attack Stat', 'Stat');

		INSERT INTO Item_Owns
		VALUES ('Calcium', 'Increases Attack Stat', NULL);

		INSERT INTO Item_Owns2
		VALUES ('Increases Special Attack Stat', 'Stat');

		INSERT INTO Item_Owns
		VALUES ('PP Up', 'Increases Special Attack Stat', NULL);

		COMMIT;

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

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Thunder Stone', 'Slateport City', 'Hoenn');

		COMMIT;

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Hyper Potion', 'Slateport City', 'Hoenn');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Max Ether', 'Slateport City', 'Hoenn');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Great Ball', 'Slateport City', 'Hoenn');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Rare Candy', 'Slateport City', 'Hoenn');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Awakening', 'Azalea Town', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Ether', 'Azalea Town', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Ultra Ball', 'Azalea Town', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Leaf Stone', 'Azalea Town', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Max Potion', 'Azalea Town', 'Johto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Super Potion', 'Pewter City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Fire Stone', 'Pewter City', 'Kanto');

		INSERT INTO Sells(ItemName, LocationName, RegionName)
		VALUES ('Rare Candy', 'Pewter City', 'Kanto');

COMMIT;