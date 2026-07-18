extends Node2D
class_name Trees

var noise: FastNoiseLite
var rng: RandomNumberGenerator

func generate_matrix(dimension: Vector2i, rng_seed: Variant) -> Matrix:
    rng = RandomNumberGenerator.new()
    rng.seed = hash(rng_seed)

    noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    noise.seed = rng_seed
    noise.fractal_lacunarity = 0.5
    noise.fractal_octaves = 2
    noise.frequency = 0.08
    var blur := 0.7

    var offset := Vector2(rng.randf() * dimension.x, rng.randf() * dimension.y)
    return Matrix.new(dimension).map_in_place(func(x, y, existing_element):
        var chance = chance_of_spawning(Vector2i(x, y))
        if rng.randf() > chance:
            return 0

        var sample := Vector2(x + offset.x, y + offset.y)
        return ((noise.get_noise_2dv(sample) + 1.0) / 2.0) * (1.0 - blur)
    )

func chance_of_spawning(pos: Vector2i) -> float:
    var elevation = %game.elevation.get_at2i(pos)

    var center = %game.water_depth.get_at2i(pos) # most fruitful elevation
    var radius_above = 0.2 # too steep/high falls off over this range
    var radius_below = 0.25 # muddy/underwater falls off much faster

    if elevation >= center:
        return clampf(1.0 - (elevation - center) / radius_above, 0.0, 1.0)
    else:
        return clampf(1.0 - (center - elevation) / radius_below, 0.0, 1.0)
