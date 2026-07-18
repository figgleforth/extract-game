extends Node2D
class_name Water

# positive value representing how deep the water is

# depth of the water is relative to the WATER_ELEVATION const
func generate_matrix(dimension: Vector2i, water_elevation: float) -> Matrix:
    return Matrix.new(dimension).map_in_place(func(x, y, existing_element):
        var pos = Vector2i(x, y)
        var elevation = %game.elevation.get_at2i(pos)
        var depth = water_elevation - elevation
        return maxf(0.0, depth)
    )
