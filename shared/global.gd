extends Node

static var BELOW := Vector3i(0, -1, 0) # Y- in Godot
static var ABOVE := Vector3i(0,  1, 0) # Y+ in Godot
static var STAY  := Vector3i.ZERO

# Ground plane movement (XZ in Godot)
static var NORTH := Vector3i(0, 0, -1)
static var SOUTH := Vector3i(0, 0,  1)
static var EAST  := Vector3i(1, 0,  0)
static var WEST  := Vector3i(-1, 0, 0)

static func inverse_direction(dir: Vector3i) -> Vector3i:
    match dir:
        BELOW: return ABOVE
        ABOVE: return BELOW
        NORTH: return SOUTH
        SOUTH: return NORTH
        EAST:  return WEST
        WEST:  return EAST
        _: return Vector3i.ZERO

signal time_scaled(new_scale)

const max_timescale := 64
const min_timescale := -10

var elapsed := 0.0
var delta := 0.0
var timescale := 1

var time_divisions := 0:
    set(val):
        time_divisions = clampi(val, min_timescale + 1, max_timescale)
        if time_divisions == 0:
            Engine.time_scale = 1.0
        elif time_divisions < 0:
            Engine.time_scale = 1.0 / abs(time_divisions)
        elif time_divisions > 0:
            Engine.time_scale = 1.0 * abs(time_divisions)

        time_scaled.emit(Engine.time_scale)
        print("time * ", Engine.time_scale, "(", val, ")")

var background_color: Color:
    set(val):
        background_color = val
        RenderingServer.set_default_clear_color(val)

var screen_size: Vector2i:
    get: return Vector2i(
        ProjectSettings.get('display/window/size/viewport_width'),
        ProjectSettings.get('display/window/size/viewport_height')
    )

var screen_size_f: Vector2:
    get: return Vector2(
        ProjectSettings.get('display/window/size/viewport_width'),
        ProjectSettings.get('display/window/size/viewport_height')
    )

static var _transaction_counter: int = 0
func next_transaction_id() -> int:
    _transaction_counter += 1
    return _transaction_counter

func _ready():
    G.background_color = Color.BLACK

func _process(d):
    delta = d
    elapsed += delta

    if Input.is_action_just_pressed('time_plus'):
        time_divisions += 1
    elif Input.is_action_just_pressed('time_minus'):
        time_divisions -= 1
    elif Input.is_action_just_pressed('time_reset'):
        time_divisions = 1

    if Input.is_action_just_pressed('ui_cancel'):
        get_tree().quit()

    if Input.is_action_just_pressed('toggle_full_screen'):
        var curr = DisplayServer.window_get_mode()
        if curr == DisplayServer.WINDOW_MODE_FULLSCREEN:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        else:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func sine(speed: float = 1.0, offset: float = 0.0) -> float:
    return sin((Time.get_ticks_msec() / 1000.0 + offset) * speed)

func cosine(speed: float = 1.0, offset: float = 0.0) -> float:
    return cos((Time.get_ticks_msec() / 1000.0 + offset) * speed)

func sine01(speed: float = 1.0, offset: float = 0.0) -> float:
    return (sine(speed, offset) + 1.0) / 2.0

func cosine01(speed: float = 1.0, offset: float = 0.0) -> float:
    return (cosine(speed, offset) + 1.0) / 2.0

func now() -> float:
    return Time.get_ticks_msec() / 1000.0

func random_color() -> Color:
    return Color.from_hsv(randf(), randf(), randf(), 1.0)

# @file_path must begin with res://
func read_file_to_string(file_path: String) -> String:
    var file_content = ""
    if FileAccess.file_exists(file_path):
        var file_access = FileAccess.open(file_path, FileAccess.READ)
        if file_access:
            file_content = file_access.get_as_text()
            file_access.close()
        else:
            print("Error opening file: ", file_path)
    else:
        print("File does not exist: ", file_path)
    return file_content
