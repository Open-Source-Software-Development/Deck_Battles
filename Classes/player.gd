extends Resource

## Stores the data and such for a single player of Cardtorium
class_name Player

## Emitted when the player finishes drawing their cards
signal cards_drawn(cards: Array[Card])
## Emitted when one or more cards are removed from the hand
signal cards_removed(old_cards: Array[Card], new_cards: Array[Card])
## Emitted when the player clears fog
signal fog_cleared(tiles: Array[Vector2i])
## Emitted when the player loses vision
signal fog_placed(tiles: Array[Vector2i])

## How many cities the player owns
@export var cities: int
## How many cards a player can have in their hand
@export var hand_size: int = 7
## How much territory the player owns
@export var owned: int
## The player's local id. Is set by the game object
@export var local_id: int
## The player's name. TODO need to figure out where to set this. Maybe somewhere in main menu?
@export var name: String
## Stores the tiles which have yet to be discovered. An undiscovered tile is
## denoted by false, discovered by true
@export var discovered: Array
## Location of the home base.
@export var base_position: Vector2i
## How many resources the player owns
@export var resources: int = 3
## How many resources per turn the player earns
@export var rpt: int = 2
## The player's deck. The front of the array is the top of the deck.
@export var deck: Array[Card]
## The player's hand
@export var hand: Array[Card]
## How much territory the player has
@export var territory: int

## Creates a new player resource from scratch
func _init(board_size: Vector2i, _deck: Array[Card]):
	randomize()
	discovered = []
	for x in range(board_size.x):
		discovered.append([])
		for y in range(board_size.y):
			discovered[x].append(false)
	# Claims territory in a 1-tile radius
	deck = _deck

## Sets up player data
func setup(game: Game, base_position: Vector2i, index: int):
	var board_size = game.board.SIZE
	# Clears the fog in a 2-tile radius around the home base
	for x in range(base_position.x - 2, base_position.x + 3):
		if x < 0:
			continue
		elif x >= board_size.x:
			break
		for y in range(base_position.y - 2, base_position.y + 3):
			if y < 0:
				continue
			elif y >= board_size.y:
				break
			discovered[x][y] = true
	# Sets local index
	self.local_id = index
	# Claims territory in a 1-tile radius
	game.claim_territory(base_position, 1, index)
	# Places home base
	game.place_city(base_position)
	cities = 1

## Called right before the player's turn begins
func begin_turn():
	# Increments resources
	resources += rpt
	# Sets hand size
	hand_size = max(hand_size, cities)
	# Draws cards until the hand is full
	var current_hand_size = len(hand)
	var drawn: Array[Card] = []
	for i in range(current_hand_size, hand_size):
		var card: Card = deck.pop_front()
		drawn.append(card)
		self.hand.append(card)
	# Lets the renderer know that it can do its thing
	self.cards_drawn.emit(self.hand)

## Clears the fog from an array of tiles
func clear_fog(tiles: Array[Vector2i]):
	for tile in tiles:
		self.discovered[tile.x][tile.y] = true
	fog_cleared.emit(tiles)

## Puts the fog back (may be used for a spell in the future)
func add_fog(tiles: Array[Vector2i]):
	for tile in tiles:
		self.discovered[tile.x][tile.y] = false
	fog_placed.emit(tiles)

## Shuffles a card into the back of the player's deck
func shuffle_card(card: Card):
	# Start with a 25% chance to put it at the back
	var pos = len(self.deck)
	var min_pos = len(self.deck) / 2
	var place_threshold = 0.25
	var thresh_inc = 1.5 / float(pos)
	var random = randf()
	# If the chance fails, move position closer to the front and increase the
	# chance to insert it here. By the time that you get to the halfway point of the deck,
	# there is a 100% chance to insert the card
	while random > place_threshold and pos > min_pos:
		place_threshold += thresh_inc
		random = randf()
		pos -= 1
	# Places the card at the location
	self.deck.insert(pos, card)

## Removes the nth card from the player's hand and shuffles it back
## into the deck
func remove_from_hand(index: int):
	var old_hand: Array[Card] = []
	for card in hand:
		old_hand.append(card)
	var card: Card = self.hand.pop_at(index)
	self.resources -= card.cost
	cards_removed.emit(old_hand, hand)
	shuffle_card(card)

## Calculates resources per turn
func calculate_rpt():
	rpt = 2 + (territory / 20)
