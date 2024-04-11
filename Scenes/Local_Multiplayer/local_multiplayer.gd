extends Node2D

var troop_scene = preload ("res://Scenes/Rendering/rendered_troop.tscn")
var card: Card

const TILE_SIZE = 64
@onready var game: Game = $Game
var selected_index = -1
var selected_tile: Vector2i = Vector2i()
signal card_placed(card_index: int)
@onready var move_renderer = $MoveRender
@onready var hand_renderer = $GUI_Renderer/HandRenderer
#@onready var ter_renderer = $TerrainRenderer
var active_unit: Unit = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Renders the background
	var board: Board = game.board
	var background: Sprite2D = $Background
	background.region_rect.size = TILE_SIZE * Vector2(board.SIZE.x, board.SIZE.y)
	# Renders the tiles
	var terrain: TileMap = $TerrainRenderer
	terrain.board = board
	# terrain.render_all()
	# Renders fog
	var fog: TileMap = $FogRenderer
	fog.setup(board)
	# Sets up hand rendering
	for player in board.players:
		hand_renderer.connect_to_player(player)
	board.players[0].begin_turn()
	game.render_topbar.emit(board.turns, board.players[board.current_player])

	var camera = $Camera2D
	camera.selected_tile.connect(self.on_selected_tile)
	hand_renderer.card_selected.connect(self.on_card_selected)
	game.turn_ended.connect(on_turn_ended)

func on_card_selected(card_index: int):
	selected_index = card_index
		
func on_selected_tile(pos: Vector2i):
	selected_tile = pos
	check_and_place_card()

	# Tester code for topbar until we have actual things that change it
	#game.board.players[game.board.current_player].resources -= 1
	#game.render_topbar.emit(game.board.turns, game.board.players[game.board.current_player])

	var tile_content = game.board.units[selected_tile.x][selected_tile.y]
	if tile_content != null and tile_content is Troop and active_unit == null:
		if tile_content.owned_by != game.board.current_player:
			return
		var troop = tile_content as Troop
		if troop.has_moved or troop.just_placed:
			move_renderer.draw_current(troop.pos)
		else:
			troop.build_graph(selected_tile.x, selected_tile.y, game.board)
			move_renderer.clear_move_outlines() # Clear previous move outlines
			move_renderer.draw_move_outlines(troop.move_graph.keys(), selected_tile) # Draw move outlines
		active_unit = troop
	elif tile_content != null and tile_content is Troop:
		# defender
		var troop = tile_content as Troop
		if troop.owned_by == game.board.current_player:
			return
		if troop == active_unit:
			move_renderer.clear_move_outlines()
			active_unit = null
			return
		var dist = floor(Vector2(active_unit.pos).distance_to(Vector2(troop.pos)))
		
		if dist <= active_unit.rng:
			move_renderer.clear_move_outlines() # Clear move outlines if not a troop
			if active_unit is Troop and active_unit != troop:
				active_unit.attack_unit(troop)
				active_unit = null
	elif active_unit != null:
		# Checks if the move is valid
		if active_unit.move_graph == null:
			move_renderer.clear_move_outlines()
			active_unit = null
			return
		elif selected_tile not in active_unit.move_graph:
			move_renderer.clear_move_outlines()
			active_unit = null
			return
		
		# Clears the move outlines
		move_renderer.clear_move_outlines()
		if active_unit is Troop:
			game.troop_move(active_unit, selected_tile)
		deselect_unit()

func deselect_unit():
	# Clears the move outlines
	move_renderer.clear_move_outlines()
	active_unit = null

## Must first select card to place on a tile
func check_and_place_card():
	if selected_index != - 1:
		if selected_tile != null:
			var tile_content = game.board.units[selected_tile.x][selected_tile.y]
			if tile_content != null and tile_content is Troop:
				# Troop already exists on the selected tile, don't allow card placement
				return
			if not game.board.buildings[selected_tile.x][selected_tile.y] is City:
				return
			var current_player = game.board.current_player
			if not game.board.territory[selected_tile.x][selected_tile.y] == current_player:
				return
			game.place_from_hand(selected_index, selected_tile.x, selected_tile.y)
			selected_index = -1
			selected_tile = Vector2i()
		else:
			# Deselect any selected tile
			selected_tile = Vector2i()

func on_turn_ended(prev_player: int, current_player: Player):
	deselect_unit()
	
## Renders a troop card by adding it to the scene tree
func render_troop(troop: Troop, pos: Vector2i):
	var instance = troop_scene.instantiate()
	instance.prepare_for_render(troop, game)
	instance.position = Vector2(pos) * TILE_SIZE
	add_child.call_deferred(instance)

func render_city(city: City):
	add_child.call_deferred(city)

func claim_territory():
	if active_unit == null:
		return
	if active_unit.owned_by == game.board.territory[active_unit.pos.x][active_unit.pos.y]:
		game.claim_territory(active_unit.pos, 1, active_unit.owned_by)
	deselect_unit()
