extends Control

signal attack_pressed
signal claim_pressed
signal end_turn_pressed

@onready var atk = $MarginContainer/ColorRect/MarginContainer/HBoxContainer/Button
@onready var claim = $MarginContainer/ColorRect/MarginContainer/HBoxContainer/Button2
@onready var end_turn = $MarginContainer/ColorRect/MarginContainer/HBoxContainer/Button3