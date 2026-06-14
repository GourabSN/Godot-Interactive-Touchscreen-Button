@icon("res://Interactive Touchscreen Button.svg")
class_name InteractiveTouchscreenButton
extends TextureButton

const DefaultValues := {
    "expand" : true,
    "ignore_texture_size" : true,
    "stretch_mode" : TextureButton.STRETCH_KEEP_ASPECT_CENTERED,
    "action_mode" : TextureButton.ACTION_MODE_BUTTON_PRESS,
    "focus_mode" : TextureButton.FOCUS_NONE,
}

@export_custom(PROPERTY_HINT_INPUT_NAME, "") var input_action:StringName 
@export var use_default_values := true
@export var touchscreen_only := false

var touch_index := 0
var released := true

func _init():
    if use_default_values:
        for k in DefaultValues.keys():
            self.set(k, DefaultValues.get(k))

    if touchscreen_only and not DisplayServer.is_touchscreen_available():
        hide()


func press():
    var event = InputEventAction.new()
    event.action = input_action
    event.pressed = true
    Input.parse_input_event(event)
    released = false


func release():
    var event = InputEventAction.new()
    event.action = input_action
    event.pressed = false
    Input.parse_input_event(event)
    released = true


func is_in(pos:Vector2) -> bool:
    if int(pos.x) in range(global_position.x, global_position.x + size.x):
        if int(pos.y) in range(global_position.y, global_position.y + size.y):
            return true 
    return false


func _input(event):
    if event is InputEventScreenTouch:
        # 1. ALWAYS process the release event to reset internal state,
        # even if the button is currently disabled.
        if not event.pressed:
            if touch_index == event.index:
                release()
            return

        # 2. If the button is disabled, we ignore the press event.
        # Because we handled 'not event.pressed' above, the button 
        # will still reset properly when the finger is lifted.
        if disabled:
            return

        # 3. Handle the press logic
        if is_in(event.position):
            if released:
                touch_index = event.index
                press()
            else:
                # Handle multi-touch interference
                release()
