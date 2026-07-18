extends RefCounted
class_name Matrix #

signal did_set(at, vaule) # the signal to rely on when coding logic, it is called for every single set.
signal did_swap(a, b) # maybe useful for animations or something

var size: Vector2i = Vector2i(1, 1)
var array := []

func _init(dimension: Vector2i):
    size = dimension
    for x in range(size.x):
        var row := []
        for y in range(size.y):
            row.append(null)
        array.append(row)

func _to_string():
    return "{a}".format({a = array})

func fill_with(it: Variant) -> Matrix:
    for x in range(size.x):
        for y in range(size.y):
            array[x][y] = it
    return self

func fill_with_array(new_array: Array):
    clear()

    assert(new_array.size() == (size.x * size.y))
    for i in range(size.x * size.y):
        set_ati(i, new_array[i])


# block = func(x, y, existing_element)
func map_in_place(block: Callable) -> Matrix:
    for x in range(size.x):
        for y in range(size.y):
            if block:
                array[x][y] = block.call(x, y, array[x][y])
    return self

# block = func(x, y, existing_element)
func each(block: Callable):
    for x in range(size.x):
        for y in range(size.y):
            if block:
                block.call(x, y, array[x][y])

func select(block: Callable) -> Matrix:
    var new_grid := Matrix.new(self.size)
    for x in range(size.x):
        for y in range(size.y):
            if block:
                var new_pos = Vector2i(x, y)
                var new_value = null
                if block.call(new_value): # if it returns true, we keep it
                    new_value = array[x][y]

                new_grid.set_at(new_pos, new_value)

    return new_grid

func clear(value: Variant = null):
    for x in range(size.x):
        for y in range(size.y):
            array[x][y] = value

func get_row(at: int) -> Array:
    if at < 0 or at >= size.x: return []
    return array[at]

func get_at2i(pos: Vector2i) -> Variant:
    if out_of_bounds_at(pos): return null
    return array[pos.x][pos.y]

func get_at(x: int, y: int) -> Variant:
    if out_of_bounds_at(Vector2i(x,y)): return null
    return array[x][y]

func set_at(at: Vector2i, value: Variant) -> bool:
    if out_of_bounds_at(at): return false
    array[at.x][at.y] = value
    did_set.emit(at, value) # the signal to rely on when coding logic, it is called for every single set.
    return true

func set_ati(index: int, value: Variant):
    @warning_ignore('integer_division')
    var pos := Vector2i(index % size.x, index / int(size.x))
    set_at(pos, value)

func swap(a: Vector2i, b: Vector2i) -> bool:
    if out_of_bounds_at(a) || out_of_bounds_at(b): return false
    var thing_a = get_at2i(a)
    var thing_b = get_at2i(b)
    set_at(a, thing_b)
    set_at(b, thing_a)

    # swap signal for each of the pieces
    # maybe useful for animations or something
    did_swap.emit(a, b)
    did_swap.emit(b, a)
    return true

func out_of_bounds_at(at: Vector2i) -> bool:
    return at.x < 0 or at.x >= size.x or at.y < 0 or at.y >= size.y
