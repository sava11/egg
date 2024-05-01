drop trigger if exists ins_check_before;
CREATE TRIGGER ins_check_before before insert ON orders FOR EACH ROW
BEGIN 
UPDATE games SET games.in_storage=games.in_storage-new.in_order WHERE id=new.game_id;
end;

drop trigger if exists ins_check_after;
CREATE TRIGGER ins_check_after after insert ON orders FOR EACH ROW
BEGIN 
UPDATE orders_data SET order_sum = order_sum +cast((select price from games where games.id=new.game_id)*new.in_order as float) where id=new.order_id;
end;

drop trigger if exists upd_check;
CREATE TRIGGER upd_check before UPDATE ON orders FOR EACH ROW
BEGIN 
	if old.in_order>new.in_order then
		UPDATE games SET games.in_storage=games.in_storage+(old.in_order-new.in_order) WHERE id=new.game_id;
	else
		UPDATE games SET games.in_storage=games.in_storage-(new.in_order-old.in_order) WHERE id=new.game_id;
	end if;
end;

drop trigger if exists upd_check_after;
CREATE TRIGGER upd_check_after after update ON orders FOR EACH ROW
BEGIN 
	if old.in_order>new.in_order then
		UPDATE orders_data SET order_sum = order_sum-
(select price from games where games.id=new.game_id)*cast((old.in_order-new.in_order) as float) where id=new.order_id;
	else
		UPDATE orders_data SET order_sum = order_sum +
(select price from games where games.id=new.game_id)*cast((new.in_order-old.in_order) as float) where id=new.order_id;
	end if;
end;

drop trigger if exists del_check;
CREATE TRIGGER del_check before DELETE ON orders FOR EACH ROW
BEGIN 
UPDATE games SET games.in_storage=games.in_storage+old.in_order WHERE id=old.game_id;
end;
#доделать удаление!
drop trigger if exists del_check_after;
CREATE TRIGGER del_check_after after DELETE ON orders FOR EACH ROW
BEGIN
	UPDATE orders_data SET order_sum = order_sum-
(select price from games where games.id=old.game_id)*cast((old.in_order) as float) where id=old.order_id;

end;

#доделать удаление из списка orders
DROP TRIGGER IF EXISTS del_order_check;
CREATE TRIGGER del_order_check BEFORE DELETE ON orders_data FOR EACH ROW
BEGIN
    DELETE FROM orders WHERE orders.order_id = OLD.id;
END;