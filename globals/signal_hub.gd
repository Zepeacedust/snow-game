extends Node

signal create_bridge(bridge : Bridge)
signal bridge_detatch(bridge : Bridge)

signal refresh_ice(ammount : float)

signal modify_bridge_meter(meter : float, recharge : float)

signal entered_no_bridge_zone()

signal exited_no_bridge_zone()

signal goal_reached

signal reset_level
signal select_level(level : PackedScene)

signal level_select_screen
signal credits_screen
signal main_menu
