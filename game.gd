extends Node2D
class_name Game

# todo: stop manually placing nodes in main.tscn. Instead, rename this to Main, main.rb, and programmatically add all the matrix nodes.
# todo: write base generator that they can inherit from. They all implement generate() or something like that, which is called when in _ready(). the generate() can be aliased with regenerate() to basically override the generation.

const size := Vector2i(128, 72)
const water_elevation = 0.0 # middle of the elevation scale -1..1 for now

# debug stuff
@export var debug_render_compound_pool: bool:
    set(val):
        debug_render_compound_pool = val
        draw_to_sprite()

@export var debug_render_compound_heatmap: bool:
    set(val):
        debug_render_compound_heatmap = val
        draw_to_sprite()

const debug_sprite_scale := Vector2(10, 10) # this scale perfectly scales the `size` perfectly to fit my 1280x720 res

var elevation: Matrix
var tree_density: Matrix
var water_depth: Matrix
var steepness: Matrix
var movement_cost: Matrix
var compound_pool: Matrix # contains hard pixel stamps, 1.0 = compound, else = not compound
var compounds: Matrix # contains stamps of compounds
var compound_heatmap: Matrix
var entities: Matrix

var active_entities: Array
var touched_positions: Array
var compound_positions: Array # cache

var tick_timer: Timer
var debug_sprite: Sprite2D

func _ready():
    var e := Entity.new()
    e.position = Vector2i((%game.size * randf()).round())
    touched_positions = [e.position]
    active_entities.append(e)

    debug_sprite = Sprite2D.new()
    debug_sprite.scale = debug_sprite_scale
    debug_sprite.centered = false
    #debug_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(debug_sprite)

    # todo: clean up this stinky generate_matrix API
    elevation = %elevation.generate_matrix(size, randf())
    water_depth = %water.generate_matrix(size, water_elevation)
    tree_density = %trees.generate_matrix(size, randf())
    steepness = %steepness.generate_matrix(elevation)
    movement_cost = %movement_cost.generate_matrix(size)
    compound_pool = %compound_pool.generate_matrix(size)
    compounds = %compounds.generate_matrix()
    compound_heatmap = %compound_heatmap.generate_matrix()
    entities = %entities.generate_matrix()


    tick_timer = Timer.new()
    tick_timer.autostart = true
    tick_timer.wait_time = 0.3
    tick_timer.timeout.connect(func():
        tick()
        draw_to_sprite()
    )
    add_child(tick_timer)
    tick()
    draw_to_sprite()

func tick() -> void:
    for e: Entity in active_entities:
        var p := e.position
        touched_positions.append(p)
        var neighs := [Vector2i.UP, Vector2i(1, -1), Vector2i.RIGHT, Vector2i(1, 1), Vector2i.DOWN, Vector2i(-1, 1), Vector2i.LEFT, Vector2i(-1, -1)] # index 0 represents north, index 1 ne, 2 e, 3 se, 4 s, 5 sw, 6 w, 7 nw
        var highest_heat = -1
        var highest_heat_index = -1
        for i in range(neighs.size()):
            var dir := neighs[i] as Vector2i
            var heat = compound_heatmap.get_at2i(p + dir)
            if heat == null: heat = 0.0

            var value = maxf(heat, 0) # don't let it go below zero
            if value >= highest_heat:
                highest_heat = value
                highest_heat_index = i

        var direction = neighs[highest_heat_index]
        e.position += direction

func draw_to_sprite():
    debug_sprite.texture = null
    var image := Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
    elevation.each(func(x, y, value):
        var normalized = (value + 1.0) / 2.0
        var c = Color.SADDLE_BROWN.lerp(Color.WHITE, normalized) # 1.0 - normalized => invert the water to be mountains basically
        image.set_pixel(x, y, c)
    )
    water_depth.each(func(x, y, value):
        var elevation_color := image.get_pixel(x, y)
        var final_color = elevation_color.lerp(Color.BLUE, value)
        image.set_pixel(x, y, final_color)
    )
    tree_density.each(func(x, y, value):
        var elevation_color := image.get_pixel(x, y)
        var final_color = elevation_color.lerp(Color.SEA_GREEN, value)
        image.set_pixel(x, y, final_color)
    )
    if debug_render_compound_pool:
        var color := Color.PURPLE
        color.a = 0.5
        compound_pool.each(func(x, y, value):
            if value < 1.0: return
            image.set_pixel(x, y, color)
        )

    if debug_render_compound_heatmap:
        compound_heatmap.each(func(x, y, distance_to_nearest_compound):
            var ground_color := image.get_pixel(x, y) as Color
            if distance_to_nearest_compound:
                var color := Color.from_hsv(0.0, 0.0, distance_to_nearest_compound, 0.5).lerp(ground_color, 1.0 - distance_to_nearest_compound)
                image.set_pixel(x, y, color)
            return
        )

    for p: Vector2i in touched_positions:
        image.set_pixelv(p, Color.TOMATO)

    compounds.each(func(x, y, value):
        if value:
            image.set_pixel(x, y, Color.BLACK)
        return
    )

    image.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
    debug_sprite.texture = ImageTexture.create_from_image(image)
