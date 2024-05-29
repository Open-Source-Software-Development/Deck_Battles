extends TroopAttribute

# Logic for fortify attribute

var bonus: int

func setup(attribute_id: int, game: Game, troop: Troop):
	super.setup(attribute_id, game, troop)
	bonus = int(troop.base_stats.defense * 0.5)
	logger.debug('troop_attribute', '(FORTFY) Adding defense bonus of %d' % bonus)
	parent.defense += bonus


func on_moved(from: Vector2i, to: Vector2i):
	var b_to = board.buildings[to.x][to.y]
	var b_fr = board.buildings[from.x][from.y]
	
	# Defendable is building attribute 0
	if b_to != null and (b_to is City or 0 in b_to.attr_ids):
		if b_fr != null and (b_fr is City or 0 in b_fr.attr_ids):
			return
		logger.debug('troop_attribute', '(FORTFY) Adding defense bonus of %d' % bonus)
		parent.defense += bonus
	else:
		if b_fr != null and (b_fr is City or 0 in b_fr.attr_ids):
			logger.debug('troop_attribute', '(FORTFY) Removing defense bonus')
			parent.defense -= bonus

	
func reset():
	var b = board.buildings[parent.pos.x][parent.pos.y]
	if  b != null and (b is City or 0 in b.attr_ids):
		logger.debug('troop_attribute', '(FORTFY) Adding defense bonus of %d' % bonus)
		parent.defense += bonus
