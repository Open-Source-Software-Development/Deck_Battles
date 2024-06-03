extends Resource

## Base class for troop
class_name TroopAttribute


## Stores data on the attribute description
@export var attribute: Attribute
## Troop object which the attribute is attached to
var parent: Troop
## The game state
var board: Board
## Used to print debug messages
var logger

## Attaches the troop attribute to a game object and a troop object.
## Also sets up the attribute's description.
func setup(attribute_id: int, game: Game, troop: Troop):
	attribute = load("res://Attributes/Troops/Data/attribute_{0}.tres".format({0: attribute_id}))
	parent = troop
	board = game.board
	logger = game.logger

# Virtual function which can be overwritten by children
func on_moved(from: Vector2i, to: Vector2i):
	pass

func on_attack(defender: Unit):
	pass

# If an attr doesn't effect the counter damage have it return 1
func on_attacked(attacker: Troop) -> int:
	return 1

## Virtual function which overrides movement costs.
## Overrides to this function can return a non-null value to change the move calculation.
## Otherwise, returning null uses the default troop calculation.
## For information on the parameters, see [method Troop._calc_move_cost]
func calc_move_cost(strength: float, from: Vector2i, to: Vector2i, board: Board) -> Dictionary:
	return {}

## Virtual function which overrides fog clearing.
## Overrides to this function can return a non-null value to change the fog clearing.
## Otherwise, returning null uses the default.
func clear_fog(pos: Vector2i):
	return null

## Virtual function which allows an attribute to add actions to a troop
func build_action() -> Action:
	return null

## Allows attributes with state to reset at the end of a turn
func reset():
	pass
