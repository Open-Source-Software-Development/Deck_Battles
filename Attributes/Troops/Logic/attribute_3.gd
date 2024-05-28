extends TroopAttribute

# Contains logic for acuity attribute

var bonus: int

func setup(attribute_id: int, game: Game, troop: Troop):
	super.setup(attribute_id, game, troop)
	bonus = 1
	logger.debug('troop_attribute', '(TALL) Adding range bonus of %d' % bonus)
	parent.rng += bonus

func on_moved(from: Vector2i, to: Vector2i):
	var b_to = board.buildings[to.x][to.y]
	var b_fr = board.buildings[from.x][from.y]
	
	# tall is building attribute id 6
	if b_to != null and 6 in b_to.attr_ids:
		if b_fr != null and 6 in b_to.attr_ids:
			return
		logger.debug('troop_attribute', '(TALL) Adding range bonus of %d' % bonus)
		parent.rng += bonus
	else:
		if b_fr != null and 6 in b_to.attr_ids:
			logger.debug('troop_attribute', '(TALL) Removing range bonus')
			parent.rng -= bonus

func reset():
	if 6 in board.buildings[parent.pos.x][parent.pos.y].attr_ids:
		logger.debug('troop_attribute', '(TALL) Adding range bonus of %d' % bonus)
		parent.rng += bonus
