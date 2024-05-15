extends Control
var data={}
@onready var tags_cont=$c/Panel/tags
@onready var auths_cont =$c2/Panel/authors
func _ready():
	data.merge({"all_authors":get_tree().current_scene.get_authors_list()})
	data.merge({"all_tags":get_tree().current_scene.get_tags_list()})
	$panel/names/id.text=data.id
	$panel/names/name.text=data.name
	$panel/cont/count/count.value=int(data.count)
	$panel/cont/price/price.value=float(data.price)
	$panel/release_date.text=data.release_date
	$panel/texts/text.text=data.text
	#$panel/img.texture=load(data.image)
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
	if data.has("authors"):
		for e in data.all_authors:
			var tag=Button.new()
			tag.toggle_mode=true
			tag.focus_mode=Control.FOCUS_NONE
			tag.text=e
			auths_cont.add_child(tag)
			tag.toggled.connect(
				Callable(
					func(type):
						if type:
							auths_cont.move_child(tag,0)
							data.authors.append(tag.text)
							
							var utag=preload("res://mats/game_card/tag/tag.tscn").instantiate()
							utag.get_node("cont/tag").text=e
							utag.get_node("cont/close").button_down.connect(
								Callable(func():
									tag.button_pressed=false
									utag.queue_free())
							)
							$panel/panel/sc_a/auth_cont.add_child(utag)
						else:
							data.authors.remove_at(data.authors.find(tag.text))
							for x in $panel/panel/sc_a/auth_cont.get_children():
								if x.has_node("cont/tag") and x.get_node("cont/tag").text==tag.text:
									x.queue_free())
			)
			tag.button_pressed=data.authors.any(Callable(func(x):return x==tag.text))
	
	_on_release_date_text_changed($panel/release_date.text)
func _on_close_button_down():
	queue_free()



func _on_apply_button_down():
	if can and data.id!="0":
		var cur_tags=sqlc.querry("select id,name from tags where id in (select tag_id from tags_connections tc where tc.game_id="+$panel/names/id.text+");")
		for e in cur_tags:
			if !data.tags.any(Callable(
				func(x):
					return str(e[1])==x)):
					sqlc.querry("call remove_tag_from_game("+$panel/names/id.text+",\""+str(e[0])+"\");")
		for e in data.tags:
			sqlc.querry("call add_tag_to_game("+str($panel/names/id.text)+",\""+e+"\");")
		var cur_authors=sqlc.querry("select id,author from authors where id in (select author_id from authors_connections ac where ac.game_id="+$panel/names/id.text+");")
		
		for e in cur_authors:
			if !data.authors.any(Callable(
				func(x):
					return str(e[1])==x)):
					sqlc.querry("call remove_author_from_game("+$panel/names/id.text+",\""+str(e[0])+"\");")
		for e in data.authors:
			sqlc.querry("call add_author_to_game("+str($panel/names/id.text)+",\""+e+"\");")
		var date1:String=$panel/release_date.text.replace(".","-")
		var sp=date1.split("-",false)
		var date:String=sp[2]+"-"+sp[1]+"-"+sp[0]
		sqlc.querry("call update_game(\""+$panel/names/id.text+"\",\""+$panel/names/name.text +"\",\"" +data.img_link +"\","+ str($panel/cont/price/price.value) +",\""+ date +"\","+ str(int($panel/cont/count/count.value)) +",\""+ $panel/texts/text.text +"\");")
		get_tree().current_scene.update_all()
	elif data.id=="0" and can==true:
		var date1:String=$panel/release_date.text.replace(".","-")
		var sp=date1.split("-",false)
		var date:String=sp[2]+"-"+sp[1]+"-"+sp[0]
		var dtd=sqlc.querry("select add_game(\'"+$panel/names/name.text +"\',\"" +data.img_link +"\","+ str($panel/cont/price/price.value) +",\'"+ date +"\',"+ str(int($panel/cont/count/count.value)) +",\""+ $panel/texts/text.text +"\");")[0]
		print(dtd)
		data.id=dtd
		$panel/names/id.text=data.id
		var cur_tags=sqlc.querry("select id,name from tags where id in (select tag_id from tags_connections tc where tc.game_id="+$panel/names/id.text+");")
		for e in cur_tags:
			if !data.tags.any(Callable(
				func(x):
					return str(e[1])==x)):
					sqlc.querry("call remove_tag_from_game("+$panel/names/id.text+",\""+str(e[0])+"\");")
		for e in data.tags:
			sqlc.querry("call add_tag_to_game("+str($panel/names/id.text)+",\""+e+"\");")
		var cur_authors=sqlc.querry("select id,author from authors where id in (select author_id from authors_connections ac where ac.game_id="+$panel/names/id.text+");")
		
		for e in cur_authors:
			if !data.authors.any(Callable(
				func(x):
					return str(e[1])==x)):
					sqlc.querry("call remove_author_from_game("+$panel/names/id.text+",\""+str(e[0])+"\");")
		for e in data.authors:
			sqlc.querry("call add_author_to_game("+str($panel/names/id.text)+",\""+e+"\");")
		
		get_tree().current_scene.update_all()

func _on_add_tag_button_down():
	$c.show()

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
	var one_or_more_visible=0
	for e in tags_cont.get_children():
		if new_text!="":
			e.visible=e.text.contains(new_text)
		else:
			e.show()
		one_or_more_visible+=int(e.visible)
	$c/Panel/cont/add_tag.disabled=bool(one_or_more_visible)


func _on_aname_text_changed(new_text):
	var one_or_more_visible=0
	for e in auths_cont.get_children():
		if new_text!="":
			e.visible=e.text.contains(new_text)
		else:
			e.show()
		one_or_more_visible+=int(e.visible)
	$c2/Panel/cont/add_author.disabled=bool(one_or_more_visible)
	#$panel/auths/anme/pns.visible=new_text!=""


func _on_add_author_button_down():
	$c2.show()


func _on_author_close_button_down():
	$c2.hide()


func _on_add_author_to_authors_button_down():
	var tag=Button.new()
	tag.toggle_mode=true
	tag.focus_mode=Control.FOCUS_NONE
	tag.text=$c2/Panel/cont/fauthor.text
	auths_cont.add_child(tag)
	tag.toggled.connect(
		Callable(
			func(type):
				if type:
					auths_cont.move_child(tag,0)
					data.authors.append(tag.text)
					
					var utag=preload("res://mats/game_card/tag/tag.tscn").instantiate()
					utag.get_node("cont/tag").text=tag.text
					utag.get_node("cont/close").button_down.connect(
						Callable(func():
							tag.button_pressed=false
							utag.queue_free())
					)
					$panel/panel/sc_a/auth_cont.add_child(utag)
				else:
					data.authors.remove_at(data.authors.find(tag.text))
					for x in $panel/panel/sc_a/auth_cont.get_children():
						if x.has_node("cont/tag") and x.get_node("cont/tag").text==tag.text:
							x.queue_free())
	)
	tag.button_pressed=data.authors.any(Callable(func(x):return x==tag.text))


func _on_add_tag_to_tags_button_down():
	var tag=Button.new()
	tag.toggle_mode=true
	tag.focus_mode=Control.FOCUS_NONE
	tag.text=$c/Panel/cont/ftag.text
	tags_cont.add_child(tag)
	tag.toggled.connect(
		Callable(
			func(type):
				if type:
					tags_cont.move_child(tag,0)
					data.tags.append(tag.text)
					
					var utag=preload("res://mats/game_card/tag/tag.tscn").instantiate()
					utag.get_node("cont/tag").text=tag.text
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


func _on_img_link_text_changed(new_text:String):
	get_tree().current_scene.get_net_image($img_control/Panel/img,new_text,data.name+"_temp")


func _on_cancel_img_change_button_down():
	$panel.show()
	$img_control.hide()
	$img_control/Panel/img.texture=null
	if $img_control/cont/img_link.text!=data.img_link:
		DirAccess.remove_absolute(get_tree().current_scene.chache+data.name+"_temp."+get_tree().current_scene.get_file_by_name(data.name))
	$img_control/cont/img_link.text=data.img_link


func _on_apply_img_change_button_down():
	$panel.show()
	$img_control.hide()
	$panel/img.texture=$img_control/Panel/img.texture
	data.img_link=$img_control/cont/img_link.text
	DirAccess.remove_absolute(get_tree().current_scene.chache+data.name+"_temp."+get_tree().current_scene.get_file_by_name(data.name))
	


func _on_show_link_change_menu_button_down():
	$panel.hide()
	$img_control.show()
	$img_control/cont/img_link.text=data.img_link
