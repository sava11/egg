extends Control
@onready var chache="temp/"
@onready var items=			  $cont/ctrl/Panel/games/sc_i/item_cont
@onready var orders=		  $cont/ctrl/Panel/order/hbc/order_panel/sc_o/order_list
@onready var order_items_cont=$cont/ctrl/Panel/order/hbc/item_panel
@export_range(0.001,9999999) var update_timer:float=60

func _ready():
	TranslationServer.set_locale("ru")
	for e in $cont/ctrl/Panel.get_children():
		e.hide()
	check_tabbar(0)
	_get_items()
	_get_orders()
	if orders.get_child_count()>0:
		cur_opend_order=orders.get_child(1).name
func _get_orders():
	for e in orders.get_children():
		if e.get_index()!=0:
			e.name="deleted_object"+str(e.get_index())
			e.queue_free()
	for e in order_items_cont.get_children():
		e.name="deleted_object"+str(e.get_index())
		e.queue_free()
	var data:Array=sqlc.querry("SELECT * FROM orders_data;")
	for e in data:
		var b=preload("res://mats/main/order_button/order_button.tscn").instantiate()
		b.get_node("order").text="№"+str(e[0])
		b.name="order_"+str(e[0])
		orders.add_child(b)
		var list=preload("res://mats/game_card/order_cont.tscn").instantiate()
		list.get_node("crdnum/num").text=str(e[1])
		list.id=e[0]
		list.get_node("datelabel/date").text=e[4][0]
		var items:Array=sqlc.querry("select * from games where games.id in (select game_id from orders where order_id="+str(e[0])+");")
		if e[2]:
			list.get_node("order/status").text=tr("SUCCES")
			b.get_node("del").queue_free()
			b.modulate=Color(0,0.9,0.1,1)
		else:
			list.get_node("order/status").text=tr("WAIT")
			b.get_node("del").button_down.connect(Callable(self,"delete_order").bind(e[0]))
			b.modulate=Color(0.75,0.7,0,1)
		list.get_node("order_sum/num").text=str(e[3])
		b.get_node("order").button_down.connect(Callable(self,"show_items").bind(b.name))
		for i in items:
			var itm=preload("res://mats/game_card/panel.tscn").instantiate()
			itm.data.merge({
			"id":str(i[0]),
			"name":i[1],
			"price":str(i[3]),
			"release_date":i[4][0],
			"count":str(i[5]),
			"count_in_order":str(sqlc.querry("select in_order from orders where order_id="+str(e[0])+" and game_id="+str(i[0])+";")[0][0]),
			"text":i[6],
			"order_status":e[2]
			})
			itm.order_item=true
			itm.get_node("remove").visible=list.get_node("order/status").text==tr("WAIT")
			itm.get_node("remove").button_down.connect(Callable(self,"delete_item").bind(str(e[0]),itm.data.id,itm.data.count_in_order))
			itm.get_node("cont/pac/count/count").value_changed.connect(Callable(self,"count_changed").bind(str(e[0]),itm.data.id,itm.data.count_in_order))
			var author_list=[]
			for author in sqlc.querry("select author from authors where id in 
			(select author_id from authors_connections where game_id="+str(e[0])+") order by id;"):
				author_list.append(Array(author)[0])
			itm.data.merge({"authors":author_list})
			if i[2]!="":
				if FileAccess.file_exists(chache+i[1]+"."+get_file_by_name(i[1])):
					itm.get_node("cont/img").texture=load(chache+i[1]+"."+get_file_by_name(i[1]))
				else:
					get_net_image(itm.get_node("cont/img"),i[2],i[1])
			list.get_node("sc_i/list").add_child(itm)
		order_items_cont.add_child(list)
		list.name=b.name
		list.hide()
		_on_order_types_item_selected($cont/ctrl/Panel/order/order_types.selected)
	if cur_opend_order!="":
		show_items(cur_opend_order)
var cur_opend_order:=""
func show_items(ord_id:String):
	cur_opend_order=ord_id
	for e in order_items_cont.get_children():e.hide()
	order_items_cont.get_node(ord_id).show()
func _get_items():
	for e in items.get_children():
		e.queue_free()
	var data:Array=sqlc.querry("SELECT * FROM games;")
	var i=0
	
	for e in data:
		var itm=preload("res://mats/game_card/panel.tscn").instantiate()
		#print(e)
		itm.data.merge({
			"id":str(e[0]),
			"name":e[1],
			"price":str(e[3]),
			"release_date":e[4][0],
			"count":str(e[5]),
			"text":e[6],
			"order_status":false
			})
		var author_list=[]
		for author in sqlc.querry("select author from authors where id in 
		(select author_id from authors_connections where game_id="+str(e[0])+") order by id;"):
			author_list.append(Array(author)[0])
		itm.data.merge({"authors":author_list})
		if e[2]!="":
			if FileAccess.file_exists(chache+e[1]+"."+get_file_by_name(e[1])):
				itm.get_node("cont/img").texture=load(chache+e[1]+"."+get_file_by_name(e[1]))
			else:
				get_net_image(itm.get_node("cont/img"),e[2],e[1])
		items.add_child(itm)

func get_net_image(s:TextureRect,img:String,filename:String):
	var http_request = FileDownloader.new()
	http_request.name=str(randi())
	add_child(http_request)
	http_request.connect("downloads_finished",Callable(self,"end").bind(s,http_request.get_path()))
	http_request.file_urls=[img]
	http_request.custom_names={0:filename}
	http_request.save_path=chache
	http_request.start_download()

func end(s:TextureRect,a:NodePath):
	var type=get_file_by_name(s.get_parent().get_node("id_game/name").text)
	var f=FileAccess.open(chache+s.get_parent().get_node("id_game/name").text+"."+type,FileAccess.READ)
	var b=f.get_buffer(f.get_length())
	f.close()
	var img = Image.new()
	img.call("load_"+type+"_from_buffer",b)
	var r = ImageTexture.new()
	r.set_image(img)
	s.texture=r
	get_node(a).queue_free()

func get_file_by_name(word:String):
	var type=""
	for e in DirAccess.get_files_at(chache):
		if e.contains(word):
			type=e.split(".")[1]
	return type


func _on_close_button_down():
	get_tree().quit(0)
func _on_flwn_button_down():
	if DisplayServer.window_get_mode()!=DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
func _on_mn_button_down():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
var tmp_pos:Vector2i
var clicked=false
func _on_gui_input(event):
	if $cont/item_bar/win_btns.visible:
		if event is InputEventMouseButton:
			if event.button_index==1 and !event.pressed:
				clicked=false
			if event.button_index==1 and event.pressed and clicked==false:
				tmp_pos=DisplayServer.window_get_position()-DisplayServer.mouse_get_position()
				clicked=true
		if event is InputEventMouseMotion:
			if clicked:
				DisplayServer.window_set_position(DisplayServer.mouse_get_position()+tmp_pos)

func check_tabbar(tab):
	for e in $cont/ctrl/Panel.get_children():e.hide()
	if tab==0: $cont/ctrl/Panel/games.show()
	if tab==1:$cont/ctrl/Panel/order.show()
func _on_tab_bar_tab_changed(tab):
	check_tabbar(tab)
var temp:float=0
func _process(delta):
	if temp>=update_timer:
		_get_items()
		temp=0

func _on_add_order_button():
	var order_id=sqlc.querry("select add_order()")
	_get_orders()

func delete_order(id:int):
	if has_order(str(id)):
		sqlc.querry("call remove_order("+str(id)+");")
		_get_orders()
		_get_items()

func has_order(order:String):
	return order_items_cont.has_node("order_"+order)

func delete_item(order_id,item_id,count):
	if has_order(order_id):
		sqlc.querry("call remove_order_item("+order_id+", "+item_id+","+str(count)+");")
		_get_orders()
		_get_items()


func count_changed(value:int,order_id:String,item_id:String,check_value):
	if value!=int(check_value):
		sqlc.querry("call set_order_item_count("+order_id+", "+item_id+","+str(value)+");")
		_get_orders()
		_get_items()

func order_type(index:int):
	return $cont/ctrl/Panel/order/order_types.get_item_text(index)
func _on_order_types_item_selected(index):
	for e in orders.get_children():
		if !e.name.contains("deleted"):
			if e==$cont/ctrl/Panel/order/hbc/order_panel/sc_o/order_list/add_order:
				e.visible=order_type(index)=="WAIT" or order_type(index)=="ALL"
			else:
				if order_items_cont.get_node(str(e.name)).get_node("order/status").text==tr(order_type(index)) or order_type(index)=="ALL":
					e.show()
				else:
					e.hide()
func get_uncompleted_orders():
	var list:PackedStringArray=[]
	for e in orders.get_children():
		if !e.name.contains("deleted"):
			if (e!=$cont/ctrl/Panel/order/hbc/order_panel/sc_o/order_list/add_order
			and order_items_cont.get_node(str(e.name)).get_node("order/status").text==tr("WAIT")):
				list.append(e.name)
	return list
func _on_price_spin_value_changed(value):
	$cont/ctrl/Panel/games/popup/VBoxContainer/price_cont/price.value=value
