//=============================================================================
// ChunkTrail.
//=============================================================================
class ChunkTrail extends Effects;

#exec OBJ LOAD FILE=..\Botpack\textures\flakGlow.utx PACKAGE=WarEffects.FlakGlow

defaultproperties
{
	Physics=10
	DrawType=7
	bTrailerSameRotation=true
	LifeSpan=0.5
	Texture=Texture'FlakGlow.fglow_a00'
	DrawScale=0.35
	Skins=/* Array type was not detected. */
	Style=3
	Mass=30
}