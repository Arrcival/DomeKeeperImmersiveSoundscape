extends "res://content/gamemode/assignments/Assignments.gd"

func fadeRetrievalMusicIn(currentCarrier:String):
	super.fadeRetrievalMusicIn(currentCarrier)
	$DesperationLayer1.stream = null
	$DesperationLayer2.stream = null
