class_name ExperienceCalculator
extends Node

static func max_for_level (level: int):
	level = maxi(0, level)
	
	if level <= 20:
		return ceilf(20 * log(level + 2))
	else:
		return ceilf(pow(level, 2) - 265.70)
