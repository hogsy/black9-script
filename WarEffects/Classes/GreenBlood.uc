class GreenBlood extends Blood;

#exec OBJ LOAD FILE=textures\SmokeGreen.utx PACKAGE=WarEffects.SmokeGreen

simulated function SpawnEmitter()
{
	// FIXME - need green blood emitter
}

defaultproperties
{
	SSprites[0]=Texture'SmokeGreen.gs_A00'
	SSprites[1]=Texture'SmokeGreen.gs2_A00'
	SSprites[2]=Texture'SmokeGreen.gs3_A00'
	Pause=0.07
	Texture=Texture'SmokeGreen.gs2_A00'
}