extends TroopAttribute

# Logic for the Surge attribute

func build_action() -> Action:
	logger.debug('troop_attribute', '(SURGE) Building the \'Surge\' action')
	var action: Action = Action.new()
	action.name = "Surge"
	action.description = attribute.description
	action.setup(parent.game, surge)
	return action

func surge():
	logger.log('troop_attribute', '(Surge) Damaging units in a 2-tile radius')
	logger.indent('troop_attribute')
	for x in range(parent.pos.x - 2, parent.pos.x + 3):
		if x < 0:
			continue
		elif x >= board.SIZE.x:
			break
		for y in range(parent.pos.y - 2, parent.pos.y + 3):
			if y < 0:
				continue
			elif y >= board.SIZE.y:
				break
			if board.units[x][y] == null:
				continue
			var defender: Unit = board.units[x][y]
			if (abs(defender.pos.x - parent.pos.x) == 2) or (abs(defender.pos.y - parent.pos.y) == 2):
				apply_surge_damage(defender, false)
			else:
				apply_surge_damage(defender, true)
	# set the disabled counter
	parent.disabled = 1

func apply_surge_damage(defender: Unit, close: bool):
	if defender.pos == parent.pos: return
	var atk_force  = parent.attack * float(parent.health)/float(parent.base_stats.health)
	var def_force = defender.defense * float(defender.health)/float(defender.base_stats.health)
	var damage = (atk_force / (atk_force+def_force)) * parent.attack
	var surge_damage = damage * 1.225
	if close: surge_damage *= 1.225
	
	defender.health -= surge_damage
	defender.damaged.emit()
	if defender.health <= 0:
		defender.health = 0
		parent.game.remove_unit(defender)
