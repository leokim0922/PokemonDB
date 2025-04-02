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
		VALUES (5, 'Sturdy -The Pokemon cannot be knocked out by a single hit as long as its HP is full. One-hit KO moves will also fail to knock it out. ');

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

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (1, 'Pound', 40, 100, 35, 'Normal physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Fighting physical attack', 'Fighting');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (2, 'Karate Chop', 50, 100, 25, 'Fighting physical attack');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack, may hit twice', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (3, 'Double Slap', 15, 85, 10, 'Normal physical attack, may hit twice');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack, may hit multiple times', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (4, 'Comet Punch', 18, 85, 15, 'Normal physical attack, may hit multiple times');

		INSERT INTO Move_Associates2(MoveEffect, TypeName)
		VALUES ('Normal physical attack', 'Normal');
		INSERT INTO Move_Associates1(MoveID, MoveName, Power, Accuracy, PowerPoints, MoveEffect)
		VALUES (5, 'Mega Punch', 80, 85, 20, 'Normal physical attack');

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

	-- INSERT POKEMON with Associated Type & Ability & Learns
		BEGIN
			AddPokemonWithTypeAbilityLearns(1, 'A grass-poison type Pokemon that grows flowers as it evolves. Known for its sweet scent.', 'Bulbasaur', 'Grass', 101, 201);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(2, 'It evolves from Bulbasaur. The seed on its back grows into a large plant as it matures.', 'Ivysaur', 'Grass', 102, 202);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(3, 'Known for its powerful solar beam attack. It is fully grown with an enormous plant on its back.', 'Venusaur', 'Grass', 103, 203);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(4, 'A fire-type Pokemon that burns with great intensity, often using its flame to intimidate opponents.', 'Charmander', 'Fire', 104, 204);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(5, 'It evolves from Charmander and is known for its fiery tail flame that burns fiercely.', 'Charmeleon', 'Fire', 105, 205);
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
			AddPokemonWithTypeAbilityLearns(10, 'It is a bug-type Pokemon with a soft, green body, known for its adorable appearance and simple nature.', 'Caterpie', 'Bug', 106, 205);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(11, 'It evolves from Caterpie and forms a cocoon to undergo its metamorphosis.', 'Metapod', 'Bug', 107, 206);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(12, 'A graceful butterfly Pokemon with beautiful wings, it uses powders for defense.', 'Butterfree', 'Bug', 108, 207);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(13, 'Known for its quick and agile flying abilities, it is a normal and flying-type Pokemon.', 'Pidgey', 'Normal', 109, 208);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(14, 'It evolves from Pidgey and is skilled at aerial combat, using powerful wing attacks.', 'Pidgeotto', 'Normal', 110, 209);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(15, 'A powerful and majestic bird known for its speed and aerial acrobatics.', 'Pidgeot', 'Normal', 111, 210);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(16, 'It is a normal-type Pokemon with a fast-moving and agile nature, known for its quick attacks.', 'Rattata', 'Normal', 112, 211);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(17, 'A tougher and stronger version of Rattata, it is adept at using its teeth and claws in battle.', 'Raticate', 'Normal', 113, 212);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(18, 'It is a snake-like Pokemon that specializes in stealthy movements and venomous attacks.', 'Ekans', 'Poison', 114, 213);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(19, 'It evolves from Ekans and has a fearsome presence with powerful poison-based attacks.', 'Arbok', 'Poison', 115, 214);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(20, 'A dog-like Pokemon with a friendly demeanor, it is known for its fire-based attacks and loyal nature.', 'Growlithe', 'Fire', 116, 215);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(21, 'It evolves from Growlithe and is a fierce and loyal guardian of its territory.', 'Arcanine', 'Fire', 117, 216);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(22, 'It is a tadpole Pokemon with powerful water abilities and a distinctive spiral pattern.', 'Poliwag', 'Water', 118, 217);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(23, 'It evolves from Poliwag and is skilled in both water and fighting moves.', 'Poliwhirl', 'Water', 119, 218);
		END;
		/

		BEGIN
			AddPokemonWithTypeAbilityLearns(24, 'A massive turtle-like Pokemon that controls water and is equipped with powerful attacks.', 'Politoed', 'Water', 120, 219);
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

	-- INSERT EvolvesInto
		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (1, 2, 'Level 16'); -- Example: Bulbasaur to Ivysaur

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (2, 3, 'Level 32'); -- Example: Ivysaur to Venusaur

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (4, 5, 'Level 16'); -- Example: Charmander to Charmeleon

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (5, 6, 'Level 36'); -- Example: Charmeleon to Charizard

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (7, 8, 'Level 16'); -- Example: Squirtle to Wartortle

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (8, 9, 'Level 36'); -- Example: Wartortle to Blastoise

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (10, 11, 'Level 20'); -- Example: Caterpie to Metapod

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (11, 12, 'Level 30'); -- Example: Metapod to Butterfree

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (13, 14, 'Level 16'); -- Example: Pidgey to Pidgeotto

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (14, 15, 'Level 36'); -- Example: Pidgeotto to Pidgeot

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (16, 17, 'Level 16'); -- Example: Rattata to Raticate

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (18, 19, 'Level 20'); -- Example: Ekans to Arbok

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (20, 21, 'Use Fire Stone'); -- Example: Growlithe to Arcanine

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (22, 23, 'Use Water Stone'); -- Example: Poliwag to Poliwhirl

		INSERT INTO EvolvesInto(PreEvolutionID, PostEvolutionID, Condition)
		VALUES (23, 24, 'Use Water Stone'); -- Example: Poliwhirl to Politoed

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