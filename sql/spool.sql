SET PAGESIZE 40000

SET FEEDBACK OFF

SET MARKUP HTML ON

SET NUM 24

SPOOL file_name.xls

PROMPT Table: Pokemon
SELECT * FROM Pokemon;

PROMPT Table: Type
SELECT * FROM Type;

PROMPT Table: Effect
SELECT * FROM Effect;

PROMPT Table: Belongs
SELECT * FROM Belongs;

PROMPT Table: Ability
SELECT * FROM Ability;

PROMPT Table: Possesses
SELECT * FROM Possesses;

PROMPT Table: Move_Associates2
SELECT * FROM Move_Associates2;

PROMPT Table: Move_Associates1
SELECT * FROM Move_Associates1;

PROMPT Table: Learns
SELECT * FROM Learns;

PROMPT Table: EvolvesInto
SELECT * FROM EvolvesInto;

PROMPT Table: Region
SELECT * FROM Region;

PROMPT Table: Location
SELECT * FROM Location;

PROMPT Table: AppearsIn
SELECT * FROM AppearsIn;

PROMPT Table: Gym
SELECT * FROM Gym;

PROMPT Table: Trainer_Defends
SELECT * FROM Trainer_Defends;

PROMPT Table: Owns
SELECT * FROM Owns;

PROMPT Table: Pokemart
SELECT * FROM Pokemart;

PROMPT Table: Item_Owns2
SELECT * FROM Item_Owns2;

PROMPT Table: Item_Owns
SELECT * FROM Item_Owns;

PROMPT Table: Sells
SELECT * FROM Sells;

SPOOL OFF

SET MARKUP HTML OFF

SPOOL OFF