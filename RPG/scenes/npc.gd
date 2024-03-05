extends CharacterBody2D

const npc_name = "Worker"
@onready var sprite = $AnimatedSprite2D
@onready var quest_dialog = $QuestGiver/NPCQuestDialog

func _ready():
	$RandomPath.start(quest_dialog)

func _process(delta):
	$RandomPath.process(self, delta)
	$QuestGiver.process(delta)
