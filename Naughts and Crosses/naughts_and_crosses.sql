####################################################################
#                                                                  #
# Author: GeoCubed                                                 #
#                                                                  #
# Git Hub: https://github.com/Geo-Cubed                            #
#                                                                  #
# Purpose: Creation script for the naughts and crosses minigame.   #
#                                                                  #
####################################################################

drop database if exists `naughts_and_crosses`;
create database `naughts_and_crosses`;

# Table to display the game board.
create table `naughts_and_crosses`.`game_board`(
	`id` int not null auto_increment,
    `x` enum('A', 'B', 'C') not null,
    `1` enum('X', 'O'),
    `2` enum('X', 'O'),
    `3` enum('X', 'O'),
    constraint `PK_game_board` primary key(`id`)
);

# Table to store any settings needed.
create table `naughts_and_crosses`.`setting`(
	`id` int not null auto_increment,
    `name` varchar(64) not null,
    `value` varchar(64) not null,
    constraint `PK_setting` primary key(`id`)
);

# Create the procedures used for the game.
use `naughts_and_crosses`;
delimiter |

# Display the game board in its current state.
drop procedure if exists `display_baord`|
create procedure `display_board`()
begin
	select `x`, `1`, `2`, `3` from `game_board`
    order by `id` asc;
end|

# Resets the game and sets up all the required tables.
drop procedure if exists `set_up_game_board`|
create procedure `set_up_game_board`(in game_type enum('computer', 'player'))
begin
	delete from `game_board`;
    
    insert into `game_board`(`id`, `x`)
    values (1, 'A'), (2, 'B'), (3, 'C');
    
    delete from `setting`;
    
    insert into `setting` (`name`, `value`)
    values ('game_type', game_type), ('turn_counter', '1');
    
    select `x`, `1`, `2`, `3` from `game_board` 
    order by `id` asc;
end|

# Function to get the current peice to place on the board.
drop function if exists `get_piece`|
create function `get_piece`()
returns enum('X', 'O')
begin
	declare counter int;
    set counter := (select cast(`value` as unsigned) from `setting` where `name` = 'turn_counter');
    
	if (counter % 2) = 1 then
		return ('X');
    else
		return ('O');
    end if;
end|

# Swap the current turn.
drop procedure if exists `change_turn`|
create procedure `change_turn`()
begin
	declare turn char default '1';
    declare counter int;
    
    if (select `value` from `setting` where `name` = 'current_turn') = 1 then
		set turn := '2';
	end if;
    
    update `setting`
    set `value` = turn
	where `name` = 'current_turn'; 
    
    set counter := (
		select cast(`value` as unsigned) from `setting` 
		where `name` = 'turn_counter' limit 1
	);
    
    set counter := counter + 1;
    update `setting`
    set `value` = counter
    where `name` = 'turn_counter';
end|

drop procedure if exists `move`|
create procedure `move`(in col_picked enum('1', '2', '3'), in row_picked enum('A', 'a', 'B', 'b', 'C', 'c'))
begin
    declare row_id int;
    declare output int default 0;
    declare piece char default `get_piece`();
    
    if (row_picked = 'A' or row_picked = 'a') then
		set row_id = 1;
	elseif (row_picked = 'B' or row_picked = 'b') then
		set row_id = 2;
	else
		set row_id = 3;
	end if;
    
    if col_picked = '1' then
		if (select `1` from `game_board` where `id` = row_id) is null then
			update `game_board`
			set `1` = piece
            where `id` = row_id;    
            
            set output = 1;
        end if;
    elseif col_picked = '2' then
		if (select `2` from `game_board` where `id` = row_id) is null then
			update `game_board`
            set `2` = piece
            where `id` = row_id;
            
            set output = 1;
		end if;
    else
		if (select `3` from `game_board` where `id` = row_id) is null then
			update `game_board`
            set `3` = piece
            where `id` = row_id;
            
            set output = 1;
		end if;
    end if;
    
    if output = 1 then
		call `change_turn`();
    end if;
    select output;
end|

# ineficient but seeing as it's only a 3x3 grid it's only 8 checks... which is nothing
# idealy I would implement a check based off the last placed position and then check the r c dl dr 
# this implementation would half the needed checks but would be a pain to do in sql which is why I'm not doing it.
drop function if exists `detect_win`|
create function `detect_win`(piece enum('X', 'O'))
returns int
begin
	return (0);
end|
delimiter ;