class_name Worm
extends Area2D

@export var body_segment_scene: PackedScene
@export var move_speed: float = 100
@export var steer_speed: float = 90
@export var initial_body_segment_amount: int = 3
@export var segment_to_head_distance: float = 28
@export var segment_to_segment_distance: float = 24
@export var move_speed_increase_on_collectable: float = 10

var _body_segments: Array[Area2D]

# virtual methods
func _ready() -> void:
	for i in initial_body_segment_amount:
		_add_body_segment()

func _physics_process(delta: float) -> void:
	_steer(delta)
	_move(delta)
	_update_body_segments()
	
	if Input.is_action_just_pressed("remove_last_body_segment"):
		_remove_last_body_segment()

# private methods
func _add_body_segment() -> void:
	# instantiate new segment and as child of the parent node of this main worm node
	var segment: Area2D = body_segment_scene.instantiate()
	get_parent().add_child.call_deferred(segment)
	
	# add a new body segment
	if _body_segments.size() == 0:
		var head_back_direction: Vector2 = -transform.x
		segment.global_position = global_position + head_back_direction * segment_to_head_distance
		segment.look_at(global_position)
	else:
		var last_segment: Area2D = _body_segments.back()
		var last_segment_back_direction: Vector2 = -last_segment.transform.x
		segment.global_position = last_segment.global_position + last_segment_back_direction * segment_to_segment_distance
		segment.look_at(last_segment.global_position)
	
	_body_segments.append(segment)

func _steer(delta: float) -> void:
	var rotation_input: float = Input.get_axis("rotate_left", "rotate_right")
	var steer_value: float = rotation_input * steer_speed
	rotation_degrees += steer_value * delta

func _move(delta: float) -> void:
	var move_input: float = Input.get_action_strength("move_forward")
	var forward_direction: Vector2 = transform.x # transform.x is always the right side of the worm, no matter its rotation
	var velocity: Vector2 = forward_direction * move_input * move_speed
	translate(velocity * delta)

func _update_body_segments() -> void:
	for i in _body_segments.size():
		var segment: Area2D = _body_segments[i]
		var segment_position: Vector2 = segment.global_position
		if i == 0:
			var head_position: Vector2 = global_position
			var head_to_segment_direction: Vector2 = head_position.direction_to(segment_position)
			segment.global_position = head_position + head_to_segment_direction * segment_to_head_distance
			segment.look_at(head_position)
		else:
			var previous_segment: Area2D = _body_segments[i - 1]
			var previous_segment_position: Vector2 = previous_segment.global_position
			var segment_to_previous_segment_direction: Vector2 = previous_segment_position.direction_to(segment_position)
			segment.global_position = previous_segment_position + segment_to_previous_segment_direction * segment_to_segment_distance
			segment.look_at(previous_segment_position)

func _remove_last_body_segment() -> void:
	if _body_segments.size() == 0:
		return
	var last_segment: Area2D = _body_segments.back()
	_body_segments.erase(last_segment)
	last_segment.queue_free()

func _on_area_entered(area: Area2D) -> void:
	move_speed += move_speed_increase_on_collectable
	_add_body_segment()
	area.queue_free()
