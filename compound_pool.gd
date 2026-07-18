extends Node2D
class_name Compound_Pool

# Can spawn on elevation that is > (water depth of 1m, so 0.1 guessing)

func generate_matrix(size: Vector2i) -> Matrix:
    var m := Matrix.new(size)
    var steepness = %game.steepness
    var water = %game.water_depth

    return m.map_in_place(func(x, y, value):
        var depth = water.get_at(x, y)
        var stepth = steepness.get_at(x, y) # average appears to be > 0.01 based on me eyeballing it

        var deep_enough = depth <= 0.075
        var steep_enough = stepth <= 0.03

        if deep_enough and steep_enough:
            return 1.0

        return 0.0 # no compound
    )

#.map_in_place(func(x, y, existing_element):
        #return 0.0
    #)
