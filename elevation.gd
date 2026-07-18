extends Node # elevation.gd
class_name Elevation

# 2d matrix of -1.0 .. 1.0 representing elevation
# -1.0 :: low
#  1.0 :: high

var noise: FastNoiseLite
var rng: RandomNumberGenerator

func generate_matrix(dimension: Vector2i, rng_seed: Variant) -> Matrix:
    noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    noise.seed = rng_seed
    noise.frequency = 0.042
    noise.fractal_octaves = 2
    noise.fractal_lacunarity = 0.5
    var blur := 0.7 # to avoid deep holes and high peaks

    rng = RandomNumberGenerator.new()
    rng.seed = hash(rng_seed)

    var offset := Vector2(rng.randf() * dimension.x, rng.randf() * dimension.y)

    return Matrix.new(dimension).map_in_place(func(x, y, existing_element):
        var sample := Vector2(x + offset.x, y + offset.y)
        return noise.get_noise_2dv(sample) * (1.0 - blur)
    )
