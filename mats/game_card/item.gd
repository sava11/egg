extends Panel
var data={}
var order_item:=false
func _ready():
	$cont/id_game/id/id.text=data.id
	$cont/id_game/name.text=data.name
	$cont/pac/price/prise.text=data.price
	data.merge({"image":$cont/img.texture.resource_path})
	$cont/pac/count/count.editable=!data.order_status
	if order_item:
		$cont/pac/count/count.min_value=1
		$cont/pac/count/count.value=int(data.count_in_order)
	else:
		$cont/pac/count/count.value=int(data.count)
		$cont/pac/count/count.editable=false
func _on_open_button_down():
	var adv_c=preload("res://mats/game_card/adv_card.tscn").instantiate()
	adv_c.data=data
	get_tree().current_scene.add_child(adv_c)

func _on_count_value_changed(value):
	$cont/pac/count/count.max_value=int(data.count)+value
