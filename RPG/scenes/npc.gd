extends CharacterBody2D

const npc_name = "Worker"
const mob_name = "worker"
@onready var sprite = $AnimatedSprite2D
@onready var quest_dialog = $QuestGiver/NPCQuestDialog

func _ready():
	$RandomPath.start(self)

func _process(delta):
	$QuestGiver.process(delta)

func _physics_process(delta):
	$RandomPath.process(delta)
