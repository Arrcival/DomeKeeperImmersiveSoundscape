extends "res://content/gamemode/assignments/Assignments.gd"

func init():
	super.init()
	$DesperationLayer1.stream = null
	$DesperationLayer2.stream = null


func fadeRetrievalMusicIn(currentCarrier:String):
	if currentCarrier != relicRetrievalMusicType:
		relicRetrievalMusicType = currentCarrier
		match relicRetrievalMusicType:
			"keeper1":
				$RelicRetrievalLayer1Intro.stream = preload("res://content/music/ENGINEER Relic Retrieval Layer 1 [intro].ogg")
				$RelicRetrievalLayer1Loop.stream = preload("res://content/music/ENGINEER Relic Retrieval Layer 1 [loop].ogg")
				$RelicRetrievalLayer2Loop.stream = preload("res://content/music/ENGINEER Relic Retrieval Layer 2 [loop].ogg")
				$DesperationLayer1.stream = null
				$DesperationLayer2.stream = null
			"keeper2":
				$RelicRetrievalLayer1Intro.stream = preload("res://content/music/ASSESSOR Relic Retrieval Layer 1 [intro].ogg")
				$RelicRetrievalLayer1Loop.stream = preload("res://content/music/ASSESSOR Relic Retrieval Layer 1 [loop].ogg")
				$RelicRetrievalLayer2Loop.stream = preload("res://content/music/ASSESSOR Relic Retrieval Layer 2 [loop].ogg")
				$DesperationLayer1.stream = null
				$DesperationLayer2.stream = null

	musicPlaying = true
	
	Audio.stopMusic()
	if not $RelicRetrievalLayer1Loop.playing:
		mod3 = 0.0
		$RelicRetrievalLayer1Intro.play()
		$RelicRetrievalLayer1Loop.play()
		$RelicRetrievalLayer2Loop.play()
	$MusicTween.interpolate_property($RelicRetrievalLayer1Intro, "volume_db", $RelicRetrievalLayer1Intro.volume_db, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$MusicTween.interpolate_property(self, "mod2", 0.0, 1.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$MusicTween.start() 
