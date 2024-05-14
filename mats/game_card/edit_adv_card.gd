extends Control
var data={}
@onready var tags_cont=$c/Panel/tags
func _ready():
	data.merge({"all_authors":get_tree().current_scene.get_authors_list()})
	data.merge({"all_tags":get_tree().current_scene.get_tags_list()})
	for e in data.authors:
		var tag=preload("res://mats/game_card/tag/tag.tscn").instantiate()
		tag.get_node("cont/tag").text=e
		tag.get_node("cont/close").button_down.connect(
			Callable(func():
				tag.queue_free())
		)
		$panel/panel/sc_a/auth_cont.add_child(tag)
	$panel/names/id.text=data.id
	$panel/names/name.text=data.name
	$panel/cont/count/count.value=int(data.count)
	$panel/cont/price/price.value=float(data.price)
	$panel/release_date.text=data.release_date
	$panel/texts/text.text=data.text
	$panel/img.texture=load(data.image)
	if data.has("tags"):
		for e in data.all_tags:
			var tag=Button.new()
			tag.toggle_mode=true
			tag.focus_mode=Control.FOCUS_NONE
			tag.text=e
			tags_cont.add_child(tag)
			tag.toggled.connect(
				Callable(
					func(type):
						if type:
							tags_cont.move_child(tag,0)
							data.tags.append(tag.text)
							
							var utag=preload("res://mats/game_card/tag/tag.tscn").instantiate()
							utag.get_node("cont/tag").text=e
							utag.get_node("cont/close").button_down.connect(
								Callable(func():
									tag.button_pressed=false
									utag.queue_free())
							)
							$panel/texts/tags.add_child(utag)
						else:
							data.tags.remove_at(data.tags.find(tag.text))
							for x in $panel/texts/tags.get_children():
								if x.has_node("cont/tag") and x.get_node("cont/tag").text==tag.text:
									x.queue_free())
			)
			tag.button_pressed=data.tags.any(Callable(func(x):return x==tag.text))
	_on_release_date_text_changed($panel/release_date.text)
func _on_close_button_down():
	queue_free()



func _on_apply_button_down():
	if can:
		var cur_tags=sqlc.querry("select id,name from tags where id in (select tag_id from tags_connections tc where tc.game_id="+$panel/names/id.text+");")
		for e in cur_tags:
			if !data.tags.any(Callable(
				func(x):
					return str(e[1])==x)):
					sqlc.querry("call remove_tag_from_game("+$panel/names/id.text+",\""+str(e[0])+"\");")
		for e in data.tags:
			sqlc.querry("call add_tag_to_game("+str($panel/names/id.text)+",\""+e+"\");")
		var date1:String=$panel/release_date.text.replace(".","-")
		var sp=date1.split("-",false)
		var date:String=sp[2]+"-"+sp[1]+"-"+sp[0]
		sqlc.querry("call update_game(\""+$panel/names/id.text+"\",\""+$panel/names/name.text +"\",\""+ "" +"\","+ str($panel/cont/price/price.value) +",\""+ date +"\","+ str(int($panel/cont/count/count.value)) +",\""+ $panel/texts/text.text +"\");")


func _on_add_tag_button_down():
	$c.show()

func _on_add_author_down():
	pass # Replace with function body.

var can:=false
func _on_release_date_text_changed(new_text:String):
	can=false
	if new_text.contains("."):
		var sp=new_text.split(".")
		if sp.size()==3:
			if int(sp[0])<32 and int(sp[0])>0 and int(sp[1])<13 and int(sp[1])>0 and len(sp[2])>3 and int(sp[2])>0:
				can=true


func _on_tag_close_button_down():
	$c.hide()


func _on_ftag_text_changed(new_text):
	for e in tags_cont.get_children():
		if new_text!="":
			e.visible=e.text.contains(new_text)
		else:
			e.show()
