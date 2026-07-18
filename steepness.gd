extends Node
class_name Steepness # 0.0 .. 1.0

func generate_matrix(elevation: Matrix) -> Matrix:
    var m := Matrix.new(elevation.size)

    return m.map_in_place(func(x, y, existing_element):
        # Make the border some really high cost so that entities won't attempt to go in this direction.
        if x == 0 or x == m.size.x - 1 or y == 0 or y == m.size.y - 1:
            return 10.0 # todo: do this in movement_cost instead
        var r = elevation.get_at(x+1, y)
        var l = elevation.get_at(x-1,y)
        var u = elevation.get_at(x, y+1)
        var d = elevation.get_at(x, y-1)
        var dx = (r - l) / 2.0
        var dy = (u - d) / 2.0
        var steepness = sqrt(dx*dx + dy*dy)
        return steepness
    )
