extends Control
class_name MainAlmanac

#region 主要页面
@onready var start_page: TextureRect = $StartPage
@onready var plant_page: TextureRect = $PlantPage
#endregion



#region 植物图鉴相关
var data_plant:Dictionary
const PathDataPlant := "res://data/almanac_plant.json"

## 植物卡片父节点
@onready var card_grid_container: GridContainer = $PlantPage/CardGridContainer
## 植物名字
@onready var plant_name: Label = $PlantPage/PanelContainer/AllBg/PlantName
## 描述
@onready var plant_text_1: Label = $PlantPage/PanelContainer/AllBg/ScrollContainer/VBoxContainer/PlantText1
## 参数
@onready var plant_text_2_para: VBoxContainer = $PlantPage/PanelContainer/AllBg/ScrollContainer/VBoxContainer/PlantText2Para
@onready var plant_para: HBoxContainer = $PlantPage/PanelContainer/AllBg/ScrollContainer/VBoxContainer/PlantText2Para/PlantPara
## 提示
@onready var plant_text_3_hint: Label = $PlantPage/PanelContainer/AllBg/ScrollContainer/VBoxContainer/PlantText3Hint
## 介绍
@onready var plant_text_4_introduction: Label = $PlantPage/PanelContainer/AllBg/ScrollContainer/VBoxContainer/PlantText4Introduction
## 花费
@onready var cost: HBoxContainer = $PlantPage/PanelContainer/AllBg/PlantText5EndPara/Cost
## 冷却间
@onready var cool_time: HBoxContainer = $PlantPage/PanelContainer/AllBg/PlantText5EndPara/CoolTime

## 展示植物的背景
@onready var plant_bg: TextureRect = $PlantPage/PanelContainer/PlantBg
var show_plant:PlantBase
#endregion

const PlantBgMap = {
	"Day": preload("res://assets/image/Almanac/Almanac_GroundDay.jpg"),
	"Night": preload("res://assets/image/Almanac/Almanac_GroundNight.jpg"),
	"Pool": preload("res://assets/image/Almanac/Almanac_GroundPool.jpg"),
	"Fog": preload("res://assets/image/Almanac/Almanac_GroundNightPool.jpg"),
	"Roof": preload("res://assets/image/Almanac/Almanac_GroundRoof.jpg")
	
}


func _ready() -> void:
	## 连接所有植物卡片点击信号
	init_plant_card()
	data_plant = load_json(PathDataPlant)
	change_plant_content(card_grid_container.get_child(0))

func load_json(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("文件无法打开")
		return
	
	var json_str = file.get_as_text()
	var result = JSON.parse_string(json_str)
	
	if result == null:
		print("JSON 解析失败")
		return
	
	return result

#region 植物图鉴
## 植物卡片初始化类型 连接点击信号
func init_plant_card():
	var cards_node = card_grid_container.get_children()
	for i:int in range(cards_node.size()):
		if i < Global.curr_plant.size():
			var card:Card = cards_node[i]
			card.card_init(Global.curr_plant[i])
			card.card_click.connect(change_plant_content)
		else:
			card_grid_container.remove_child(cards_node[i])
		

func change_plant_content(card:Card):
	var curr_plant_type:Global.PlantType = card.card_type
	var curr_plant_name = Global.get_plant_info(curr_plant_type, Global.PlantInfoAttribute.PlantName)
	## 名字
	plant_name.text = data_plant[curr_plant_name]["名字"]
	## 描述
	plant_text_1.text = data_plant[curr_plant_name]["描述"]
	var num_para = data_plant[curr_plant_name]["参数"].size()
	## 参数
	for i in range(num_para):
		var curr_plant_para = plant_text_2_para.get_child(i)
		var curr_key = data_plant[curr_plant_name]["参数"].keys()[i]
		curr_plant_para.get_node("Key").text = curr_key
		curr_plant_para.get_node("Value").text = data_plant[curr_plant_name]["参数"][curr_key]
	for i in range(num_para, plant_text_2_para.get_children().size()):
		plant_text_2_para.get_child(i).visible = false
		
	## 提示
	if data_plant[curr_plant_name].has("提示"):
		plant_text_3_hint.text = data_plant[curr_plant_name]["提示"]
		plant_text_3_hint.visible = true
	else:
		plant_text_3_hint.visible = false
	## 简介
	plant_text_4_introduction.text = data_plant[curr_plant_name]["简介"]
	## 花费
	cost.get_node("Value").text = str(Global.get_plant_info(curr_plant_type,  Global.PlantInfoAttribute.SunCost))
	## 冷却时间
	cool_time.get_node("Value").text = str(Global.get_plant_info(curr_plant_type,  Global.PlantInfoAttribute.CoolTime))
	cool_time.get_node("Value").text += "(秒)"
	
	## 展示植物
	create_plant(curr_plant_type, curr_plant_name)

func create_plant(curr_plant_type:Global.PlantType, curr_plant_name:String):
	var plant_scene = Global.get_plant_info(curr_plant_type, Global.PlantInfoAttribute.PlantScenes)
	var new_show_plant:PlantBase = plant_scene.instantiate()
	new_show_plant.is_idle = true
	plant_bg.add_child(new_show_plant)
	new_show_plant.position = Vector2(100,100)
	if show_plant:
		show_plant.queue_free()
	show_plant = new_show_plant
	plant_bg.texture = PlantBgMap[data_plant[curr_plant_name]["背景"]]
#endregion




## 返回开始菜单
func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.StartMenu])

## 查看植物图鉴
func _on_plant_button_pressed() -> void:
	start_page.visible = false
	plant_page.visible = true


## 返回图鉴索引
func _on_return_button_pressed() -> void:
	start_page.visible = true
	plant_page.visible = false
	
