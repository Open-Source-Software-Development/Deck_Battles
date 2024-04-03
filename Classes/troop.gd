extends Unit

## Class which represents a troop on the board.
class_name Troop

## The troop id
var id: int = 0
## Whether or not the troop has moved
var has_moved: bool = false
## Whether or not the troop has attacked
var has_atkd: bool = false
## Graph of tiles that the troop can move to.
var move_graph = null
## Stores the troop's attributes
var attributes: Array[TroopAttribute] = []
## Defense of the card
var defense: int
## Movement of the card
var movement: int


## Initiallizes a troop object from a card.
func _init(_game: Game, card: Card=null):
	self.game = _game
	self.id = card.id
	self.base_stats = card
	attack = base_stats.attack
	defense = base_stats.defense
	movement = base_stats.movement
	rng = base_stats.attack_range
	health = base_stats.health
	# Loads attributes
	for attribute_id in self.base_stats.attributes:
		# var attribute: TroopAttribute = load('res://Attributes/Troops/Logic/attribute_{0}.gd'.format({0:attribute_id})).new()
		# var desc: Attribute = load('res://Attributes/Troops/Data/attribute_{0}.tres'.format({0:attribute_id}))
		# attribute.add_description(desc)
		# attributes.append(attribute)
		pass


## Clears fog in a radius around the card
func clear_fog():
	var clear_tiles: Array[Vector2i] = []
	var temp = null
	for attribute in attributes:
		temp = attribute.clear_fog(pos)
		if temp != null:
			break
	if temp == null:
		for x_off in range(-1, 2):
			for y_off in range(-1, 2):
				var tile: Vector2i = pos + Vector2i(x_off, y_off)
				if tile.x < 0 or tile.y < 0:
					continue
				elif tile.x >= game.board.SIZE.x or tile.y >= game.board.SIZE.y:
					continue
				clear_tiles.append(tile)
	else:
		for tile in temp:
			clear_tiles.append(tile as Vector2i)
	game.board.players[owned_by].clear_fog(clear_tiles)

## Helper function which returns all tiles within a certain
## radius of the center.
func _get_surrounding(center: Vector2i, radius: int) -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	for x_off in range( - radius, radius + 1):
		for y_off in range( - radius, radius + 1):

			if x_off == 0 and y_off == 0:
				continue
			output.append(center + Vector2i(x_off, y_off))
	return output


## Builds a graph of the tiles that the unit can move to.
func build_graph(x: int, y: int, board: Board):
	var graph: Dictionary = {}
	var visited: Dictionary = {}
	var start = Vector2i(x, y)
	var frontier: Array = []
	# Elements in the frontier_data take the form
	# [strength, dist, [path_to_tile]]
	var frontier_data: Dictionary = {}
	var strength: float = float(self.base_stats.movement)
	for surround in _get_surrounding(start, 1):
		var new_strength = self._calc_move_cost(strength, start, surround, board)
		if new_strength < 0:
			continue
		# Deep copies surround for the path
		var to = Vector2i(surround.x, surround.y)
		var path = [start, to]
		# Adds nodes to the frontier
		frontier.append(to)
		frontier_data[to] = [new_strength, 0, path]
	# Runs breadth-first search
	while frontier:
		var tile = frontier.pop_front()
		strength = frontier_data[tile][0]
		var dist = frontier_data[tile][1]
		var path = frontier_data[tile][2]
		graph[tile] = path
		# If the troop has no strength left, cannot move further
		if strength <= 0:
			continue
		# Search surrounding tiles
		for surround in _get_surrounding(tile, 1):
			var new_strength = self._calc_move_cost(strength, tile, surround, board)
			if new_strength < 0:
				continue
			var to = Vector2i(surround.x, surround.y)
			var new_dist = (tile - start).length_squared()
			if to == start:
				continue
			# If the node is in the frontier, check if the current path is better or worse
			elif to in frontier_data:
				var old_strength = frontier_data[to][0]
				var old_dist = frontier_data[to][1]
				if new_strength < old_strength:
					continue
				elif new_dist >= old_dist and new_strength == old_strength:
					continue
				if to not in frontier:
					frontier.append(to)
			else:
				frontier.append(to)
			var new_path = path + [to]
			frontier_data[to] = [new_strength, new_dist, new_path]
	self.move_graph = graph


## Internal function which determines the cost of moving from a tile to a tile.[br][br]
##
## This is used in [method build_graph] to determine where a unit can move to. Attributes which
## override the [method TroopAttribute.calc_move_cost] method can change the behavior of this
## method.[br][br]
##
## [b]Parameters:[/b][br]
## [param strength]: An approximation to how many tiles this unit can move[br]
## [param from]: Tile that the unit is moving from[br]
## [param to]: Tile that the unit is moving to. Should be 1 tile away from [param from][br]
## [param board]: The state of the board. See [member Game.board][br]
## [b]Returns: [float][/b][br]
## A number which represents approximately how much farther a unit can move. A return
## of 0 indicates that the unit can no longer move after going to [param to]. A return of
## -1 indicates that the unit cannot move to [param to]. Non-integer returns are allowed.
func _calc_move_cost(strength: float, from: Vector2i, to: Vector2i, board: Board) -> float:
	print("FROM:", from)
	print("TO:", to)
	if to.x >= board.SIZE.x or to.y >= board.SIZE.y:
		return -1

	var dest_type: Board.Terrain = board.tiles[to.x][to.y]
	# Check if the destination tile contains another troop, skip if it does
	var unit_at_destination = board.units[to.x][to.y]
	if unit_at_destination != null and unit_at_destination is Troop:
		return - 1
	# Checks if any attributes override the behavior of calc_move_cost
	for attr in attributes:
		var value = attr.calc_move_cost(strength, from, to, board)
		if value != null:
			return value
	# Checks if the move is even discovered
	if not board.players[self.owned_by].discovered[to.x][to.y]:
		return - 1
	# Checks terrain type
	if dest_type == Board.Terrain.FOREST:
		return 0
	elif dest_type == Board.Terrain.MOUNTAIN:
		return 0
	elif dest_type == Board.Terrain.WATER:
		return - 1
	# TODO: Check if there is an enemy nearby to apply zone-of-control
	return max(strength - 1, 0)


## Called when the unit is attacked
func being_attacked(attacker: Unit, atk: int, attack_force: float) -> int:
	# Calculates your defense force
	var def_force = self.defense * float(health)/float(base_stats.health)
	# Damages the unit
	var damage = floor((attack_force/(attack_force+def_force))*atk)
	health -= damage
	# If the troop is dead, then it dies
	if health <= 0:
		health = 0
		game.remove_unit(self)
		return 0
	# Calculates counter damage
	var counter_damage: int = floor((def_force/(attack_force+def_force))*defense)
	return counter_damage


## Attacks another unit
func attack_unit(defender: Unit):
	if has_atkd:
		return
	# DEBUG: Remove later
	print('Before:')
	print("Attacker: {0} HP".format({0:health}))
	print("Defender: {0} HP".format({0:defender.health}))
	print()
	var atk_force  = attack * float(self.health)/float(base_stats.health)
	health -= defender.being_attacked(self, attack, atk_force)
	# If the troop is dead, then it dies
	if health <= 0:
		health = 0
		game.remove_unit(self)
	# DEBUG: Remove later
	print('After:')
	print("Attacker: {0} HP".format({0:health}))
	print("Defender: {0} HP".format({0:defender.health}))
	print()
