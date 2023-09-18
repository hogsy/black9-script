//=============================================================================
// WaterRing.
//=============================================================================
class WaterRing extends UT_RingExplosion;

#exec OBJ LOAD FILE=..\botpack\Textures\fireeffect56.utx  PACKAGE=WarEffects.Effect56

simulated function SpawnEffects()
{
}

defaultproperties
{
	RemoteRole=0
	DrawScale=0.2
	Skins=/* Array type was not detected. */
}