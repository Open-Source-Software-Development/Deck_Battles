extends TroopAttribute

# Contains the logic for scout attribute

func clear_fog(pos: Vector2i) -> Array[Vector2i]:
    var scout_tiles: Array[Vector2i] = parent._get_surrounding(pos, 2)
    return scout_tiles