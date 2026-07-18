extends Node2D
class_name Compound_Heatmap

# clampf(1.0 - distance / max_distance, 0.0, 1.0)
# 0.0 = far away
# 1.0 = center of it

# todo: entities should have their own heatmap that dynamically changes based on the compound the entity is interested in. Maybe even blended with the world heatmap, where the other compounds are faded, so the entity would still know where there's a compound.

func generate_matrix(target_num_compounds: int = 10) -> Matrix:
    var max_distance := %game.size.x as float
    var pool := %game.compound_pool as Matrix
    var m := Matrix.new(pool.size)
    m.fill_with(0.0) # 0 = far away, 1 = center of it
    m.map_in_place(func(x, y, value):
        var curr_point = Vector2i(x, y) # of current compound
        var closest = Vector2i.ONE * %game.size.x
        var distance = %game.size.x
        for p: Vector2i in %game.compound_positions:
            var d := curr_point.distance_to(p)
            if d < distance:
                distance = d
                closest = p

        return clampf(1.0 - (distance / max_distance * 2.0), 0.0, 1.0)
    )
    return m
