extends Control
@onready var chache="temp/"
@onready var editable_items=$cont/ctrl/Panel/game_adding/sc_i/item_cont
@onready var tags_cont=		$cont/ctrl/Panel/games/popup/filters/tags/sc/tags
@onready var auths_cont=		$cont/ctrl/Panel/games/popup/filters/authors/sc/cont
@onready var items=			$cont/ctrl/Panel/games/sc_i/item_cont
@onready var orders=		$cont/ctrl/Panel/order/hbc/order_panel/sc_o/order_list
@onready var order_items_cont=$cont/ctrl/Panel/order/hbc/item_panel
@export_range(0.001,9999999) var update_timer:float=60

func _ready():
	TranslationServer.set_locale("ru")
	for e in $cont/ctrl/Panel.get_children():
		e.hide()
	check_tabbar(0)
	_get_items()
	_get_orders()
	_get_editable_items()
	if orders.get_child_count()>1:
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
			"img_link":e[2],
			"price":str(i[3]),
			"release_date":i[4][0],
			"count":str(i[5]),
			"count_in_order":str(sqlc.querry("select in_order from orders where order_id="+str(e[0])+" and game_id="+str(i[0])+";")[0][0]),
			"text":i[6],
			"tags":get_tags(i[0]),
			"order_status":e[2],
			"authors":get_authors(e[0])
			})
			itm.adv_card_path="res://mats/game_card/adv_card.tscn"
			itm.order_item=true
			itm.get_node("remove").visible=list.get_node("order/status").text==tr("WAIT")
			itm.get_node("remove").button_down.connect(Callable(self,"delete_item").bind(str(e[0]),itm.data.id,itm.data.count_in_order))
			itm.get_node("cont/pac/count/count").value_changed.connect(Callable(self,"count_changed").bind(str(e[0]),itm.data.id,itm.data.count_in_order))
			
			load_image(itm.get_node("cont/img"),i[2],i[1])
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
			"img_link":e[2],
			"price":str(e[3]),
			"release_date":e[4][0],
			"count":str(e[5]),
			"text":e[6],
			"tags":get_tags(e[0]),
			"order_status":false,
			"authors":get_authors(e[0])
			})
		load_image(itm.get_node("cont/img"),e[2],e[1])
		itm.adv_card_path="res://mats/game_card/adv_card.tscn"
		items.add_child(itm)
func load_image(itm:TextureRect,link:String,iname:String):
	if link!="":
		if FileAccess.file_exists(chache+iname+"."+get_file_by_name(iname)):
			itm.texture=load(chache+iname+"."+get_file_by_name(iname))
		else:
			get_net_image(itm,link,iname)
func _get_editable_items():
	for e in editable_items.get_children():
		if e is Panel:
			e.queue_free()
	var data:Array=sqlc.querry("SELECT * FROM games;")
	var i=0
	
	for e in data:
		var itm=preload("res://mats/game_card/panel.tscn").instantiate()
		#print(e)
		itm.data.merge({
			"id":str(e[0]),
			"name":e[1],
			"img_link":e[2],
			"price":str(e[3]),
			"release_date":e[4][0],
			"count":str(e[5]),
			"text":e[6],
			"tags":get_tags(e[0]),
			"order_status":false,
			"authors":get_authors(e[0])
			})
		load_image(itm.get_node("cont/img"),e[2],e[1]+"[id]:"+itm.data.id)
		itm.adv_card_path="res://mats/game_card/edit_adv_card.tscn"
		editable_items.add_child(itm)

func get_net_image(s:TextureRect,img:String,filename:String):
	var http_request = FileDownloader.new()
	http_request.name=str(randi())
	add_child(http_request)
	http_request.connect("downloads_finished",Callable(self,"end").bind(s,str(http_request.get_path()),filename))
	http_request.file_urls=[img]
	http_request.custom_names={0:filename}
	http_request.save_path=chache
	http_request.start_download()

func end(s:TextureRect,a:String,filename:String):
	#print(get_node(a).get_stats())
	
	var ext=""
	if get_node(a).get_stats().file_name.split(".").size()>1:
		ext=get_node(a).get_stats().file_name.split(".")[1]
	if ["bmp","jpg","png","svg","webp"].any(Callable(func(x):return x==ext)):
		var f=FileAccess.open(chache+filename+"."+ext,FileAccess.READ)
		var b=f.get_buffer(f.get_length())
		f.close()
		var img = Image.new()
		#bmp,jpg,png,svg,webp
		img.call("load_"+ext+"_from_buffer",b)
		var r = ImageTexture.new()
		r.set_image(img)
		s.texture=r
	get_node(a).queue_free()

func get_file_by_name(word:String):
	for e in DirAccess.get_files_at(chache):
		if e.split(".")[0]==word:
			var ws=e.split(".")
			return ws[len(ws)-1]
	return ""
func get_tags(game_id:int):
	var exit_list=[]
	for item in sqlc.querry("select name from tags where id in (select tag_id from tags_connections tc where tc.game_id="+str(game_id)+");"):
		if !tags_cont.get_children().any(Callable(func(x):return x.text==item[0])) or tags_cont.get_child_count()==0:
			var tag=Button.new()
			tag.text=item[0]
			tag.toggle_mode=true
			tag.focus_mode=Control.FOCUS_NONE
			tag.toggled.connect(
				Callable(
					func(type):
						if type:
							tags_cont.move_child(tag,0)
							filter_data.tags.append(tag.text)
						else:
							filter_data.tags.remove_at(filter_data.tags.find(tag.text))
						filter() )
			)
			tags_cont.add_child(tag)
		exit_list.append(item[0])
	return exit_list
func get_authors(game_id:int):
	var author_list=[]
	for author in sqlc.querry("select author from authors where id in 
	(select author_id from authors_connections where game_id="+str(game_id)+") order by id;"):
		var item=Array(author)[0]
		if !auths_cont.get_children().any(Callable(func(x):return x.text==item)) or auths_cont.get_child_count()==0:
			var tag=Button.new()
			tag.text=item
			tag.toggle_mode=true
			tag.focus_mode=Control.FOCUS_NONE
			tag.toggled.connect(
				Callable(
					func(type):
						if type:
							auths_cont.move_child(tag,0)
							filter_data.authors.append(tag.text)
						else:
							filter_data.authors.remove_at(filter_data.authors.find(tag.text))
						filter() )
			)
			auths_cont.add_child(tag)
		author_list.append(item)
	return author_list
func get_authors_list():
	var l=[]
	for e in auths_cont.get_children():
		l.append(e.text)
	return l
func get_tags_list():
	var l=[]
	for e in tags_cont.get_children():
		l.append(e.text)
	return l
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
	for e in $cont/ctrl/Panel.get_children():
		if e.get_index()==tab:
			e.show()
		else:e.hide()
func _on_tab_bar_tab_changed(tab):
	check_tabbar(tab)
var temp:float=0
func _process(delta):
	if temp>=update_timer:
		_get_orders()
		_get_items()
		_get_editable_items()
		temp=0
func update_all():
	_get_orders()
	_get_items()
	_get_editable_items()
func _on_add_order_button():
	var order_id=sqlc.querry("select add_order()")
	_get_orders()

func delete_order(id:int):
	if has_order(str(id)):
		sqlc.querry("call remove_order("+str(id)+");")
		_get_orders()
		_get_items()
		_get_editable_items()

func has_order(order:String):
	return order_items_cont.has_node("order_"+order)

func delete_item(order_id,item_id,count):
	if has_order(order_id):
		sqlc.querry("call remove_order_item("+order_id+", "+item_id+","+str(count)+");")
		_get_orders()
		_get_items()
		_get_editable_items()


func count_changed(value:int,order_id:String,item_id:String,check_value):
	if value!=int(check_value):
		sqlc.querry("call set_order_item_count("+order_id+", "+item_id+","+str(value)+");")
		_get_orders()
		_get_items()
		_get_editable_items()

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

var filter_data={
	"name":"",
	"price_sort":1,
	"price":0,
	"tags":[],
	"authors":[]
}
func filter():
	for e in items.get_children():
		if (
			(e.data.name.contains(filter_data.name) or 
			str(e.data.id).contains(filter_data.name) or filter_data.name=="") and
			price_sort_by_type_(filter_data.price_sort, float(e.data.price),filter_data.price) and
			(e.data.tags.any(Callable(func(x):
				return filter_data.tags.any(Callable(func(y):
					return x==y)))) or filter_data.tags.is_empty()) and
		(e.data.authors.any(Callable(func(x):
				return filter_data.authors.any(Callable(func(y):
					return x==y)))) or filter_data.authors.is_empty())
		):
			e.show()
		else:
			e.hide()
func _on_price_spin_value_changed(value):
	filter_data.price=value
	filter()


func _on_filter_game_name_text_changed(new_text):
	filter_data.name=new_text
	filter()


func _on_sort_type_item_selected(index):
	filter_data.price_sort=index
	filter()
func price_sort_by_type_(id:int,item1:int,item2:int):
	if id==0: return item1<=item2
	if id==1: return item1>=item2
	if id==2: return item1==item2
	return true


func _on_tag_search_text_changed(new_text):
	for e in tags_cont.get_children():
		if new_text!="":
			e.visible=e.text.contains(new_text)
		else:
			e.show()


func _on_show_tags_button_down():
	$cont/ctrl/Panel/games/popup/filters/tags.visible=!$cont/ctrl/Panel/games/popup/filters/tags.visible


func _on_add_game_button_down():
	var adv_c=load("res://mats/game_card/edit_adv_card.tscn").instantiate()
	adv_c.data={
			"id":"0",
			"name":tr("UNNAMED"),
			"img_link":"",
			"price":"0",
			"release_date":"",
			"count":"0",
			"text":"",
			"tags":[],
			"order_status":false,
			"authors":[]
			}
	add_child(adv_c)


func _on_authors_button_button_down():
	$cont/ctrl/Panel/games/popup/filters/authors.visible=!$cont/ctrl/Panel/games/popup/filters/authors.visible


func _on_author_search_text_changed(new_text):
	for e in auths_cont.get_children():
		if new_text!="":
			e.visible=e.text.contains(new_text)
		else:
			e.show()
