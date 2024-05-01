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