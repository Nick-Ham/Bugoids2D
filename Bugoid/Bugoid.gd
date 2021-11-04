extends KinematicBody2D

onready var wings = $Wings
onready var sprite = $Sprite

var speed = 130
var velocity = Vector2()

var alignmentScalar = .04
var cohesionScalar = .05
var avoidanceScalar = .3
var toLightScalar = .3

var neighbors = []

func _ready():
	velocity.x = Globals.rng.randi()%100 - 50
	velocity.y = Globals.rng.randi()%100 - 50
	velocity = velocity.normalized()

func get_type():
	return "bug"

func _process(delta):
	wings.rotation = velocity.angle() 

func _physics_process(delta):
	
	var alignmentVector = find_alignment().normalized() * alignmentScalar
	var cohesionVector = find_cohesion().normalized() * cohesionScalar
	var avoidanceVector = find_avoidance().normalized() * avoidanceScalar
	var toLightVector = find_light().normalized() * toLightScalar
	
	velocity = velocity.normalized()
	velocity = (velocity + alignmentVector + cohesionVector + toLightVector + avoidanceVector).normalized() * speed
	velocity = move_and_slide(velocity)

func find_alignment():
	var alignment = Vector2()
	if !neighbors.empty():
		for each in neighbors:
			alignment += each.velocity
	return alignment

func find_cohesion():
	var cohesion = Vector2()
	if !neighbors.empty():
		for each in neighbors:
			cohesion += each.global_position
		cohesion /= neighbors.size()
		cohesion = cohesion - global_position
	return cohesion


func find_avoidance():
	var avoidance = Vector2()
	var nearestBug
	var minDistance
	var distanceTo
	
	if !neighbors.empty():
		nearestBug = neighbors[0]
		distanceTo = global_position.distance_to(nearestBug.global_position)
		minDistance = distanceTo
		for each in neighbors:
			distanceTo = global_position.distance_to(each.global_position)
			if distanceTo < minDistance:
				nearestBug = each
				minDistance = distanceTo
		
		avoidance = global_position - nearestBug.global_position
		if avoidance.length() > 100:
			avoidance = Vector2()
	
	return avoidance


func find_light():
	var lightTarget = Vector2()
	lightTarget = (Globals.lightPosition - global_position)
	return lightTarget


func _on_Detector_body_entered(body):
	if body.has_method("get_type") and !body == self:
		if !body in neighbors:
			neighbors.append(body)



func _on_Detector_body_exited(body):
	if body in neighbors:
		neighbors.erase(body)

