extends "res://content/gadgets/mushroomfarm/MyzelOverlay.gd"


func incr_buff(keeper:Keeper, bufname, bufamount:float, bufdur:float):
	super.incr_buff(keeper, bufname, bufamount, bufdur)
	var buf:TemporaryBuff = keeper.getTemporaryBuff(bufname, "myzel")
	Audio.mushroomIncreasePitch(buf.remainingDuration)
