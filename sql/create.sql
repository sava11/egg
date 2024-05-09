drop database if exists game_store;
create database if not exists game_store;

drop table if exists game_store.authors;
create table game_store.authors(
	id int unsigned NOT NULL auto_increment,
	author varchar(196) NOT null,
	primary key(id)
);ALTER TABLE game_store.authors AUTO_INCREMENT=0;

drop table if exists game_store.tags;
create table  game_store.tags(
	id int unsigned NOT NULL auto_increment,
	name varchar(256) not null,
	primary key(id)
);ALTER TABLE game_store.tags AUTO_INCREMENT=0;


drop table if exists game_store.games;
create table  game_store.games(
	id int unsigned NOT NULL auto_increment,
	title varchar(256) not null,
	image_link text,
	#image_type CHAR(10),
	price float(5,2),
	release_date Date not null,
	in_storage int not null,
	short_desc text,
	tag_list int unsigned,
	primary key(id)
);ALTER TABLE game_store.games AUTO_INCREMENT=0;

drop table if exists game_store.tags_connections;
create table game_store.tags_connections(
	game_id int unsigned NOT NULL,
	tag_id int unsigned NOT null,
	FOREIGN KEY (game_id)
	REFERENCES game_store.games(id)
	ON DELETE CASCADE,
	FOREIGN KEY (tag_id)
	REFERENCES game_store.tags(id)
	ON DELETE CASCADE
);

drop table if exists game_store.authors_connections;
create table game_store.authors_connections(
	game_id int unsigned NOT NULL,
	author_id int unsigned NOT null,
	FOREIGN KEY (game_id)
	REFERENCES game_store.games(id)
	ON DELETE CASCADE,
	FOREIGN KEY (author_id)
	REFERENCES game_store.authors(id)
	ON DELETE CASCADE
);

drop table if exists game_store.orders_data;
create table if not exists game_store.orders_data(
	id int unsigned NOT NULL auto_increment,
	card_number varchar(18),
	status bool,
	order_sum float(10,2) not null DEFAULT 0.0,
	#order_list int unsigned,
	order_date DATE,
	primary key(id)
	
);ALTER TABLE game_store.orders_data AUTO_INCREMENT=0;

drop table if exists game_store.orders;
create table if not exists game_store.orders(
	order_id int unsigned,
	game_id int unsigned,
	in_order int unsigned not null,
	FOREIGN KEY (game_id)
	REFERENCES game_store.games(id),
	FOREIGN KEY (order_id)
	REFERENCES orders_data(id)
	ON DELETE CASCADE
);