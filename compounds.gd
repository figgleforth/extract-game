extends Node2D
class_name Compounds

const min_distance_to_border := 1
const min_distance_between := 32 # what's the unit here?
const max_iterations := 1000

func generate_matrix(target_num_compounds: int = 10) -> Matrix:
    var pool := %game.compound_pool as Matrix
    var m := Matrix.new(pool.size)
    m.fill_with(0.0) # 0 = no compound, 1 = compound

    var placed_compound_points := {}
    #var compound_size = Vector2i(20, 20) # later, for now lets just place some points
    for i in range(0, max_iterations):
        if target_num_compounds == 0: return m

        var destination = Vector2i(roundf(%game.size.x * randf()), roundf(%game.size.y * randf()))
        var sample = pool.get_at2i(destination) # 1 or 0
        if sample == null: continue

        var available = !placed_compound_points.has(destination)

        if available and sample >= 1:
            var far_enough = true
            for p: Vector2i in placed_compound_points.values():
                if destination.distance_to(p) < min_distance_between:
                    far_enough = false
                    break

            if far_enough:
                placed_compound_points[destination] = destination # store itself
                m.set_at(destination, 1.0)
                target_num_compounds -= 1

    # store the compound positions so we dont have to iterate the matrix again
    %game.compound_positions = placed_compound_points.values()
    return m
