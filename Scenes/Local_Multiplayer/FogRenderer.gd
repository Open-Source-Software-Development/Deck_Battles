extends TileMap

## The game
@export var board: Board

## Sets up signal connections on game load
func setup(_board: Board):
	self.board = _board
	for player in self.board.players:
		player.fog_cleared.connect(self.clear_fog)
		player.fog_placed.connect(self.add_fog)
	self.render_all()

## Renders all of a player's fog tiles
func render_all(player: Player=null):
	var fog = []
	var discovered: Array[Vector2i] = []
	if player == null:
		player = board.players[board.current_player]
	# Adds fog to undiscovered tiles
	for x in range(board.SIZE.x):
		for y in range(board.SIZE.y):
			if not player.discovered[x][y]:
				fog.append(Vector2i(x, y))
			else:
				discovered.append(Vector2i(x,y))
	# Adds fog to world border
	for x in range(board.SIZE.x):
		fog.append(Vector2i(x, -1))
		fog.append(Vector2i(x, board.SIZE.y))
	for y in range( - 1, board.SIZE.y + 1):
		fog.append(Vector2i( - 1, y))
		fog.append(Vector2i(board.SIZE.x, y))
	
	set_cells_terrain_connect(0, fog, 0, 0)
	clear_fog(discovered)

## If a tile is discovered, re-renders the fog
func clear_fog(tiles: Array[Vector2i]):
	set_cells_terrain_connect(0, tiles, 0, -1)

func add_fog(tiles: Array[Vector2i]):
	pass

## Handles switching players
func switch_players(oldplayer, newplayer):
	# print(newplayer.discovered)
	render_all(newplayer)
