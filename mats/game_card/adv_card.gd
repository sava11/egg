extends Control
var data={}
func _ready():
	for e in data.authors:
		var lbl:Label=Label.new()
		lbl.text=e+" |"
		get_node("panel/sc_a/auth_cont").add_child(lbl)
	$panel/names/id.text=data.id
	$panel/names/name.text=data.name
	$panel/count_lbl/count.text=data.count
	$panel/prise_txt/prise.text=data.price
	$panel/release_date/Label.text=data.release_date
	$panel/texts/text.text=data.text
	$panel/img.texture=load(data.image)
	$panel/Panel/op.clear()
	$panel/Panel/op.add_item("ADD_TO_ORDER")
	for e in get_tree().current_scene.get_uncompleted_orders():
		$panel/Panel/op.add_item(e,int(e.split("_")[1]))
	$panel/Panel/count.max_value=int(data.count)
func _process(delta):
	$panel/Panel/insert.disabled=$panel/Panel/op.selected==0
func _on_close_button_down():
	queue_free()

func _on_insert_button_down():
	if get_tree().current_scene.has_order(str($panel/Panel/op.get_item_id($panel/Panel/op.selected))):
		sqlc.querry("call add_item_in_order("+str($panel/Panel/op.get_item_id($panel/Panel/op.selected))+","+str(data.id)+","+str($panel/Panel/count.value)+");")
		$panel/Panel/op.selected=0
		get_tree().current_scene._get_orders()
		get_tree().current_scene._get_items()
