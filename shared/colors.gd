extends Node

const saturation: = 0.6
const brightness: = 0.87 # 0.85

const hue_spacing: = 0.01
const hue_cycle_in_seconds: = 35

static var hue_accumulation: = 0.0:
  set(val):
    hue_accumulation = fmod(val, hue_cycle_in_seconds)

static var animate := true

func _ready() -> void:
  randomize()
  randomize_current_color()

static func randomize_current_color():
  if animate:
    hue_accumulation = randf() * hue_cycle_in_seconds

func _process(delta: float) -> void:
    if animate:
        hue_accumulation += delta

func hue01() -> float:
  return hue_accumulation / hue_cycle_in_seconds

func color_for_xy(xy: Vector2, size: Vector2, invert: bool = false, grayscale: bool = false) -> Color:
  var offset: Vector2 = xy / size
  var hue_delta_between_cells: float = float(xy.y) / float(size.y) / 3.1
  hue_delta_between_cells = fmod(hue_delta_between_cells, 1.0)
  var hue: float = fmod(hue01() + hue_delta_between_cells, 1.0)

  if grayscale:
    return Color.from_hsv(hue, 0.0, brightness, 1.0)

  if invert:
    hue = fmod((hue01() + hue_delta_between_cells + 0.5), 1.0)

  return Color.from_hsv(hue, saturation, brightness, 1.0)

func foreground() -> Color:
  var c = Color.AQUAMARINE
  c.v -= 0.35
  c.s += 0.1
  return c

func background() -> Color:
  return Color.ANTIQUE_WHITE
