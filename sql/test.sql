use game_store;

#поиск авторов по игре
select author from authors where id in
(select author_id from authors_connections where game_id=1)
order by id desc;

#поиск игр по автору
select title from games where games.id in 
(select game_id from authors_connections where author_id=1)
order by title desc;
#поискигр по дате выхода
select title from games where games.release_date between '2020-01-01' and '2021-01-31';
#поиск игр по цене
select title from games where price between 100 and 150;

#найти  игры с автором 3 в ценовой категории от 100-150
select * from games where games.id in 
(select game_id from authors_connections where 
author_id=(select id from authors where author='3')) and 
(games.price between 100 and 150)
;

#товары в конкретном заказе
select title from games where games.id in 
(select game_id from orders where order_id=3);

select * from authors_connections ac 
inner join games on ac.game_id = games.id
inner join authors on ac.author_id = authors.id 
order by title;
call add_item_in_order(3,4,6);
SELECT * FROM games;
call remove_order_item(3,4,1);
SELECT * FROM games;
call remove_order_item(3,4,2);
call remove_order_item(3,4,3);
/*SELECT * FROM games;
SELECT * FROM orders;
SELECT * FROM orders_data;
select * from tags;
select * from tags_connections;
delete from orders where game_id = 2;
delete from games where id = 2;
*/
SELECT * FROM games;
SELECT * FROM orders;
SELECT * FROM orders_data;
select * from tags;
select * from tags_connections;

#tags
select name from tags where id in (select tag_id from tags_connections tc where tc.game_id=1);

