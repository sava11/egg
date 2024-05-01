extends Control
var id=0
var gms=null
func _ready():
	$pay.visible=$order/status.text==tr("WAIT")
	$pay.disabled=!$sc_i/list.get_child_count()>0

var m:Control=null
		
func _on_pay_button_down():
	m=preload("res://mats/main/order_message.tscn").instantiate()
	m.get_node("Panel/btns/c").connect("button_down",Callable(m,"queue_free"))
	m.get_node("Panel/btns/a").connect("button_down",Callable(self,"check_pay"))
	get_tree().current_scene.add_child(m)
func check_pay():
	var txt=m.get_node("Panel/card_data/card/cn").text
	var cvc=m.get_node("Panel/card_data/card/cvc").text
	var mo=m.get_node("Panel/card_data/info/date/m").text
	var ye=m.get_node("Panel/card_data/info/date/y").text
	var money=m.get_node("Panel/card_data/info/money").text
	if money=="":
		money=m.get_node("Panel/card_data/info/money").placeholder
	var correct=true
	if !(txt.is_valid_int() and len(txt)>=8 and len(txt)%2==0):
		m.get_node("Panel/card_data/card/cn").text="UNCORRECT_CARD"
		correct=false
	if !(cvc.is_valid_int() and len(cvc)==3):
		m.get_node("Panel/card_data/card/cvc").text="err"
		correct=false
	if !(mo.is_valid_int() and len(mo)==2):
		m.get_node("Panel/card_data/date/m").text="er"
		correct=false
	if !(ye.is_valid_int() and len(ye)==4):
		m.get_node("Panel/card_data/date/y").text="err"
		correct=false
	if !(money.is_valid_float() and float(money)-float($order_sum/num.text)>=0):
		m.get_node("Panel/card_data/info/money").text="isnt exists "+$order_sum/num.text
		correct=false
	if correct:_edit()
func _edit():
	sqlc.querry("
UPDATE
	orders_data
SET
	status = true
WHERE id = "+str(id)+";
UPDATE
	orders_data
SET
	card_number ="+m.get_node("Panel/card_data/card/cn").text+"
WHERE id = "+str(id)+";
UPDATE
	orders_data
SET
	order_date = CURDATE()
WHERE id = "+str(id)+";"

)
	m.queue_free()
	get_tree().current_scene._get_orders()
	
