//=============================================================================
// UT_BlackSmoke.
//=============================================================================
class UT_BlackSmoke extends UT_SpriteSmokePuff;

#exec OBJ LOAD FILE=..\botpack\textures\SmokeBlack.utx PACKAGE=WarEffects.SmokeBlack

defaultproperties
{
	SSprites[0]=Texture'SmokeBlack.bs_a00'
	SSprites[1]=Texture'SmokeBlack.bs2_a00'
	SSprites[2]=Texture'SmokeBlack.bs3_a00'
	SSprites[3]=none
	RisingRate=70
	NumSets=3
	bHighDetail=true
	Texture=Texture'SmokeBlack.bs2_a00'
	DrawScale=2.2
	Style=4
}