extends Node2D
class_name Entities

func generate_matrix() -> Matrix:
    var m := Matrix.new(%game.size)
    m.fill_with(null)

    m.map_in_place(func(x, y, it):
        return it
    )

    return m
