extends Node

## Class which contains the logic and data required to run a game.
## Does not contain any rendering functions or input processing.
class_name Game

## Contains the game's data. Saving the board to disk allows
## saving and loading games.
var board: Board = Board.new()

## Number of players
var num_players: int

## Notifies other nodes when a set of terrain tiles is changed.
signal terrain_updated(changed: Array[Vector2i], terrain: Board.Terrain)
## Emitted when a troop is placed.
signal troop_placed(troop: Troop, pos: Vector2i)
## Emitted when a player ends their turn.
signal turn_ended(local_id: int)
## Emitted when a troop is moved
signal troop_moved(troop: Troop, path: Array)
## Emitted when a unit is removed from the board.
signal unit_removed(unit: Unit)
## Emitted right before (or maybe after) player's turn switches over
signal render_topbar(turn: int, player: Player)

# Called when the node enters the scene tree for the first time.
func _ready():
	board = Board.new()
	# Creates a new board of size 11 x 11
	var width = 11
	var height = 11
	board.setup(width, height, 2)
	num_players = 2
	render_topbar.emit(board.turns, board.players[board.current_player])


## Changes the terrain for an array of tiles
func set_terrain(terrain: Board.Terrain, location: Array[Vector2i]):
	for position in location:
		board.tiles[position.x][position.y] = terrain
	terrain_updated.emit(location, terrain)

## Takes a card as input, and places that card at position x, y.
func place_card(card: Card, x: int, y: int):
	match (card.type):
		# Places a troop card
		Card.CardType.TROOP:
			var troop: Troop = Troop.new(self, card)
			troop.owned_by = board.current_player
			board.units[x][y] = troop
			troop.pos = Vector2i(x, y)
			troop_placed.emit(troop, Vector2i(x, y))

## Places the nth card in the player's hand onto the board at position x, y
func place_from_hand(index: int, x: int, y: int):
	var player: Player = board.players[board.current_player]
	var card: Card = player.hand[index]
	player.remove_from_hand(index)
	self.place_card(card, x, y)

## Goes to the next player's turn
func end_turn():
	var prev = board.current_player
	# Updates current_player
	board.current_player += 1
	if board.current_player == num_players:
		board.current_player = 0
		board.turns += 1
	# Sets next player up to begin their turn
	render_topbar.emit(board.turns, board.current_player)
	board.players[board.current_player].begin_turn()
	
	# Lets other nodes know that a player has ended their turn
	turn_ended.emit(prev, board.players[board.current_player])

	print("end turn clicked")
	print(board.current_player)
	print(board.turns)

	

## Moves a troop from one position to another.
## WARNING: If the move is invalid, then this function will throw
## an error.
func troop_move(troop: Troop, tile: Vector2i):
	# Moves the unit
	self.board.units[troop.pos.x][troop.pos.y] = null
	self.board.units[tile.x][tile.y] = troop
	# Sets the troop's position and stores its old position
	var from = Vector2i(troop.pos.x, troop.pos.y)
	troop.pos = tile
	# Emits the move signal
	var path: Array = troop.move_graph[tile]
	troop.clear_fog()
	troop_moved.emit(troop, path)

## Removes a unit from the board
func remove_unit(unit: Unit):
	board.units[unit.pos.x][unit.pos.y] = null
	unit_removed.emit(unit)
