extends RichTextLabel

@onready var game: Game = $/root/LocalMultiplayer/Game

func _ready():
	pass

# Source Code for this found at:
		# https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html
# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text):
	# We only need to replace opening brackets to prevent tags from being parsed.
	return bbcode_text.replace("[", "[lb]")

func _on_game_render_topbar(turn: int, player: Player):
	var form_ret: String
	var actl_ret: String
	form_ret = "[center]Turn: %d\t\t\t\t\t\tPlayer: %s\t\t\t\t\t\tResources: %d\t\t\t\t\t\tRpT: %d\t\t\t\t\t\tTerritory Owned: %d\t\t\t\t\t\tCities: %d/%d\t\t\t\t\t\t[/center]"
	actl_ret = form_ret % [turn, escape_bbcode(player.name), player.resources, player.rpt, player.territory, player.cities, player.max_cities]
	
	set_text(actl_ret)
