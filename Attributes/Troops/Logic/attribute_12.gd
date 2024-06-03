extends TroopAttribute

# Contains logic for the lightning attribute

func on_attack(defender: Unit):
	var pos = defender.pos
	if board.tiles[pos.x][pos.y] == Board.Terrain.WATER:
		var lightning_tiles = defender._get_surrounding(pos, 1)
		for tile in lightning_tiles:
			var unit_at_tile = board.units[tile.x][tile.y]
			if tile == Board.Terrain.WATER and unit_at_tile != null:
				apply_lightning_damage(unit_at_tile)

func apply_lightning_damage(defender: Troop):
	var atk_force  = parent.attack * float(parent.health)/float(parent.base_stats.health)
	var def_force = defender.defense * float(defender.health)/float(defender.base_stats.health)
	var damage = (atk_force / (atk_force+def_force)) * parent.attack
	
	defender.health -= damage
	defender.damaged.emit()
	if defender.health <= 0:
		defender.health = 0
		parent.game.remove_unit(defender)
