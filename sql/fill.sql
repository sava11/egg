use game_store;

insert into authors(author) values
('3'),
('31'),
('hard bass games'),
('клянчим, получаем'),
('chuhan games')
;
select * from authors;
insert into tags(name) values
('tag1'),
('tag2'),
('tag3')
;
select * from tags;

insert into games(title,image_link, price, release_date, in_storage, short_desc) 
values
('rogue',"https://cdn.akamai.steamstatic.com/steam/apps/1443430/header.jpg?t=1651574702",100.00,'2020-05-20',10,"a beautiful world what wont to be destroyed"),
('rogue2',"",120.00,'2021-05-20',50,""),
('rogue-9',"",120.00,'1997-11-11',50,""),
('rogue3',"",150.00,'2021-05-20',10,""),
('anagin',"",750.00,'2021-05-20',50,""),
('chipushila',"",120.00,'2021-05-20',50,""),
('cu han',"",120.00,'2021-05-20',50,""),
('han cu',"",120.00,'2021-05-20',50,""),
('zalu paiva nicha',"",120.00,'2021-05-20',50,"")
;
select * from games;

insert into authors_connections(game_id,author_id) values
(1,1),(1,2),(2,1),(3,3),(3,4),(3,5),(4,3),(5,5),(6,4),(7,5),(8,4),(8,2)
;
select * from authors_connections;

insert into tags_connections(game_id,tag_id) values
(1,1),(1,2),(2,1),(3,2),(3,3),(3,1),(4,3),(5,2),(6,1),(7,2),(8,1),(8,3)
;
select * from tags_connections;

insert into orders_data(card_number,status,order_date) values
("199999999",true,'2020-05-22'),("0",false,'2020-05-24'),("199999999",true,'2020-06-02')
;
select * from orders_data;
insert into orders(order_id,game_id,in_order) values
(1,1,1),(1,2,2),(2,1,2),(3,2,2)
;
select * from orders;

select * from orders_data;
select * from games;

