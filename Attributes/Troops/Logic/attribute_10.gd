extends TroopAttribute

# Contains logic for the siege attribute

func on_attack(defender: Unit):
	if defender.card_type == Card.CardType.BUILDING:
		apply_siege_damage(defender)

func apply_siege_damage(defender: Building):
	var atk_force  = parent.attack * float(parent.health)/float(parent.base_stats.health)
	var def_force = defender.defense * float(defender.health)/float(defender.base_stats.health)
	var damage = (atk_force / (atk_force+def_force)) * parent.attack
	var siege_damage: int = floor(damage * 1.25)
	
	defender.health -= siege_damage
	defender.damaged.emit()
	if defender.health <= 0:
		defender.health = 0
		parent.game.remove_unit(defender)
