extends TroopAttribute

# Logic for fortify attribute

var bonus: int

func setup(attribute_id: int, game: Game, troop: Troop):
    super.setup(attribute_id, game, troop)
    bonus = int(troop.base_stats.defense * 0.5)

func on_loaded():
    if board.buildings[parent.pos.x][parent.pos.y] is City:
        logger.debug('troop_attribute', '(FORTFY) Adding defense bonus of %d' % bonus)
        parent.defense += bonus

func on_moved(from: Vector2i, to: Vector2i):
    # TODO: Add logic for defendable buildings
    if board.buildings[to.x][to.y] is City:
        if board.buildings[from.x][from.y] is City:
            return
        logger.debug('troop_attribute', '(FORTFY) Adding defense bonus of %d' % bonus)
        parent.defense += bonus
    else:
        if board.buildings[from.x][from.y] is City:
            logger.debug('troop_attribute', '(FORTFY) Removing defense bonus')
            parent.defense -= bonus

    
func reset():
    if board.buildings[parent.pos.x][parent.pos.y] is City:
        logger.debug('troop_attribute', '(FORTFY) Adding defense bonus of %d' % bonus)
        parent.defense += bonus