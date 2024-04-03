extends Control

var card_scene = preload ("res://Scenes/Card_Renderer/Card.tscn")

var player: Player
var XBOUND = [200, 952]
var YPOS = 550
var cards := []
var card_history := [] # Keep track of last card and current card selected
var clicks = 0
signal card_selected(card: Card)
var cardsize = Vector2(1205, 1576)

## Initializes the hand renderer by connecting it to a player's hand
func connect_to_player(p: Player):
	player = p
	player.cards_drawn.connect(render_cards)
	player.cards_removed.connect(remove_cards)

## Renders the cards in a player's hand.
func render_cards(hand: Array[Card]):

	for card_node in cards:
		card_node.queue_free()
	cards.clear()
	
	print("CARDS:", cards)
	print("HAND:", hand)
	var num_cards = len(hand)
	var increment = float(XBOUND[1] - XBOUND[0]) / num_cards
	var xpos = XBOUND[0] + increment / 2
	print("NUM_CARDS:", num_cards)
	for i in range(num_cards):
		var card = hand[i]
		var rendered = card_scene.instantiate()
		add_child(rendered)
		rendered.setup(card, i)
		call_deferred("setup_card", rendered, Vector2(xpos, YPOS), 0.12, cardsize)
		xpos += increment
	
		rendered.card_focused.connect(self.on_card_focused)
		rendered.card_unfocused.connect(self.on_card_unfocused)
		rendered.card_clicked.connect(self.on_card_clicked)
		cards.append(rendered)

func on_card_focused(card_index: int):
	if not cards[card_index].is_selected:
		cards[card_index].z_index = 1
		cards[card_index].position.y = (YPOS - (cardsize.y * 0.12) / 2) - 100

func on_card_unfocused(card_index: int):
	if not cards[card_index].is_selected:
		cards[card_index].z_index = 0
		cards[card_index].position.y = YPOS - (cardsize.y * 0.12) / 2

func on_card_clicked(card_index: int):
	if cards[card_index].is_selected:
		deselect_card(card_index)
	else:
		card_history.append(card_index)
		select_card(card_index)

func select_card(card_index: int):
	if card_history.size() > 1:
		deselect_card(card_history.pop_front())

	cards[card_index].is_selected = true
	cards[card_index].get_node("Focus").modulate.a = 1
	cards[card_index].position.y = (YPOS - (cardsize.y * 0.12) / 2) - 100
	cards[card_index].z_index = 1
	card_selected.emit(card_index)

func deselect_card(card_index: int):
	cards[card_index].is_selected = false
	cards[card_index].get_node("Focus").modulate.a = 0
	cards[card_index].z_index = 0
	cards[card_index].position.y = YPOS - (cardsize.y * 0.12) / 2

## Removes a card from the player's hand
func remove_cards(old_hand: Array[Card], new_hand: Array[Card]):
	# TODO: Add an animation here instead of just re-rendering the hand
	render_cards(new_hand)

## Helper function for positioning a card
func setup_card(rendered, pos, scale, size):
	rendered.size = size
	rendered.position = pos - (size * scale) / 2
	rendered.scale.x = scale
	rendered.scale.y = scale


func switch_hands(prev: int, curr: Player):
	print(curr.hand)
	self.render_cards(curr.hand)

