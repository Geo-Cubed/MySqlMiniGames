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

# Table to store the overall scores of the player and computer.
create table `naughts_and_crosses`.`scores`(
	`id` int not null,
    `you` int not null default 0,
    `computer` int not null default 0,
    `draws` int not null default 0,
    constraint `PK_scores` primary key(`id`)
);

# Table to display the game board.
create table `naughts_and_crosses`.`game_board`(
	`id` int not null auto_increment,
    `x` enum('A', 'B', 'C') not null,
    `1` enum('X', 'O'),
    `2` enum('X', 'O'),
    `3` enum('X', 'O'),
    constraint `PK_game_board` primary key(`id`)
);

# Create the procedures used for the game.
use `naughts_and_crosses`;
delimiter |

drop procedure if exists `display_baord`|
create procedure `display_board`()
begin
	select `x`, `1`, `2`, `3` from `game_board`
    order by `id` asc;
end|

drop procedure if exists `set_up_game_board`|
create procedure `set_up_game_board`()
begin
	delete from `game_board`;
    
    insert into `game_board`(`id`, `x`)
    values (1, 'A'), (2, 'B'), (3, 'C');
    
    select `x`, `1`, `2`, `3` from `game_board` 
    order by `id` asc;
end|

drop procedure if exists `play`|
create procedure `play`(in col_picked enum('1', '2', '3'), in row_picked enum('A', 'a', 'B', 'b', 'C', 'c'), in piece enum('X', 'O'))
begin
    declare row_id int;
    declare output int default 0;
    
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
    
    select output;
end|

delimiter ;