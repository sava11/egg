SELECT * FROM games;
call update_game(1, "chuchu", "", 300, CURDATE() , 200, "");
call add_tag_to_game(3,"tag1");
call add_author_to_game(1, "55") ;
call remove_author_from_game(1, 6) ;

SELECT * FROM games;
SELECT * FROM orders;
SELECT * FROM orders_data;
SELECT @id :=add_order();
call add_item_in_order(@id, 2, 6);
SELECT * FROM orders;
SELECT * FROM orders_data;
call remove_order_item(@id, 2, 3);
SELECT * FROM orders;
SELECT * FROM orders_data;
call set_order_item_count(@id, 2, 2);
SELECT * FROM orders;
SELECT * FROM orders_data;
call remove_order(@id);
SELECT * FROM orders;
SELECT * FROM orders_data;
#				('zalu paiva nicha',"",120.00,'2021-05-20',50,"")
select add_game('UNNAMED_d',"",336.00,'2024-12-20',3324,"adfda");