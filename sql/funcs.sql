#создание заказа
CREATE FUNCTION game_store.add_order() 
RETURNS INT DETERMINISTIC
BEGIN
    INSERT INTO orders_data(card_number, status, order_date) 
    VALUES ("0", FALSE, CURDATE());
    RETURN (SELECT COUNT(id) FROM orders_data);
END;
#создание объекта в заказе
CREATE PROCEDURE game_store.add_item_in_order(order_id int, item_id int, count_items int) 
BEGIN
	if (select count(in_order) FROM game_store.orders where orders.order_id =order_id and orders.game_id =item_id)=0 then
	    INSERT INTO orders(order_id,game_id,in_order)
	    VALUES (order_id,item_id,count_items);
	else
		UPDATE orders SET in_order=in_order+count_items where orders.order_id =order_id and orders.game_id =item_id;
	end if;
END;
#удаление заказа
CREATE PROCEDURE game_store.remove_order(order_id int)
BEGIN
    DELETE from game_store.orders_data where game_store.orders_data.id=order_id;
END;

#удаление объекта в заказе
CREATE PROCEDURE game_store.remove_order_item(order_id int, item_id int, count_items int)
BEGIN
	if (select in_order FROM game_store.orders where orders.order_id =order_id and orders.game_id =item_id)-count_items>1 THEN
		UPDATE orders SET in_order=in_order-count_items where orders.order_id =order_id and orders.game_id =item_id;
	else
		DELETE from game_store.orders where orders.order_id =order_id and orders.game_id =item_id;
	end if;
END;

#установка конкретного значения в заказе 
CREATE PROCEDURE game_store.set_order_item_count(order_id int, item_id int, count_items int)
BEGIN
	if (select count(game_id) from game_store.orders where orders.order_id=order_id and orders.game_id =item_id)>0 then
		if count_items>0 THEN
			UPDATE orders SET in_order=count_items where orders.order_id =order_id and orders.game_id =item_id;
		else
			DELETE from game_store.orders where orders.order_id =order_id and orders.game_id =item_id;
		end if;
	end if;
END;

#
CREATE PROCEDURE game_store.update_game(game_id int, game_title varchar(256),game_image_link text, 
game_price float, game_release_date Date, game_in_storage int, game_short_desc text)
BEGIN
	if (select count(title) from game_store.games where title!=game_title and id=game_id)=1 then
		update game_store.games 
		set games.title=game_title
		where title!=game_title and id=game_id;
	end if;
	if (select count(image_link) from game_store.games where image_link!=game_image_link and id=game_id)=1 then
		update game_store.games 
		set games.image_link=game_image_link
		where image_link!=game_image_link and id=game_id;
	end if;
	if (select count(price) from game_store.games where price!=game_price and id=game_id)=1 then
		update game_store.games 
		set games.price=game_price
		where price!=game_price and id=game_id;
	end if;
	if (select count(release_date) from game_store.games where release_date!=game_release_date and id=game_id)=1 then
		update game_store.games 
		set games.release_date=game_release_date
		where release_date!=game_release_date and id=game_id;
	end if;
	if (select count(in_storage) from game_store.games where in_storage!=game_in_storage and id=game_id)=1 then
		update game_store.games 
		set games.in_storage=game_in_storage
		where in_storage!=game_in_storage and id=game_id;
	end if;
	if (select count(in_storage) from game_store.games where in_storage!=game_in_storage and id=game_id)=1 then
		update game_store.games 
		set games.in_storage=game_in_storage
		where in_storage!=game_in_storage and id=game_id;
	end if;
	if (select count(short_desc) from game_store.games where in_storage!=game_short_desc and id=game_id)=1 then
		update game_store.games 
		set games.short_desc=game_short_desc
		where in_storage!=game_short_desc and id=game_id;
	end if;
END;

#add_game("UNNAMED","",336,"2024-12-20",3324,"adfda");
CREATE function game_store.add_game(game_title varchar(256),game_image_link text, 
game_price float, game_release_date Date, game_in_storage int, game_short_desc text)
RETURNS INT DETERMINISTIC
BEGIN
	insert into game_store.games(title,image_link, price, release_date, in_storage, short_desc) values
	(game_title,game_image_link,game_price, game_release_date, game_in_storage, game_short_desc);
	return (SELECT COUNT(id) FROM games);
END;

#установка тега к игре
CREATE PROCEDURE game_store.add_tag_to_game(_game_id INT, _tag_name VARCHAR(256))
BEGIN
    DECLARE _tag_id INT DEFAULT 0;
    
    -- Проверяем, существует ли тег с указанным именем
    IF (SELECT COUNT(id) FROM game_store.tags WHERE name = _tag_name) = 0 THEN
        -- Если тега не существует, добавляем его
        INSERT INTO game_store.tags(name) VALUES (_tag_name);
    END IF;
   	IF (SELECT count(id) FROM game_store.tags WHERE name = _tag_name)>0 then
   		SET _tag_id = (SELECT id FROM game_store.tags WHERE name = _tag_name);
   	END IF;
    
    -- Проверяем, существует ли игра с указанным id
    IF (SELECT COUNT(id) FROM game_store.games WHERE id = _game_id) > 0 and _tag_id!=0 THEN
        -- Проверяем, существует ли связь между игрой и тегом
        IF (SELECT COUNT(game_id) FROM game_store.tags_connections WHERE game_id = _game_id AND tag_id = _tag_id) = 0 THEN
            -- Если связи не существует, добавляем ее
            INSERT INTO game_store.tags_connections(game_id, tag_id) VALUES (_game_id, _tag_id);
        END IF;
    END IF;
END;

#установка конкретного тега к игре
CREATE PROCEDURE game_store.remove_tag_from_game(_game_id int, _tag_id int)
BEGIN
	delete from tags_connections where game_id= _game_id and tag_id=_tag_id;
END;


#установка автора к игре
CREATE PROCEDURE game_store.add_author_to_game(_game_id INT, _author_name VARCHAR(256))
BEGIN
    DECLARE _author_id INT DEFAULT 0;
    
    -- Проверяем, существует ли тег с указанным именем
    IF (SELECT COUNT(id) FROM game_store.authors WHERE author = _author_name) = 0 THEN
        -- Если тега не существует, добавляем его
        INSERT INTO game_store.authors(author) VALUES (_author_name);
    END IF;
   	IF (SELECT count(id) FROM game_store.authors WHERE author = _author_name)>0 then
   		SET _author_id = (SELECT id FROM game_store.authors WHERE author = _author_name);
   	END IF;
    
    -- Проверяем, существует ли игра с указанным id
    IF (SELECT COUNT(id) FROM game_store.games WHERE id = _game_id) > 0 and _author_id!=0 THEN
        -- Проверяем, существует ли связь между игрой и тегом
        IF (SELECT COUNT(game_id) FROM game_store.authors_connections WHERE game_id = _game_id AND author_id = _author_id) = 0 THEN
            -- Если связи не существует, добавляем ее
            INSERT INTO game_store.authors_connections(game_id, author_id) VALUES (_game_id, _author_id);
        END IF;
    END IF;
END;

#удаление автора к игре
CREATE PROCEDURE game_store.remove_author_from_game(_game_id int, _author_id int)
BEGIN
	delete from authors_connections where game_id= _game_id and author_id=_author_id;
END;