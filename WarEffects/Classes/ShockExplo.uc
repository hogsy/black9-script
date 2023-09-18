class ShockExplo extends AnimSpriteEffect;


#exec TEXTURE IMPORT NAME=ExplosionBluePal FILE=..\botpack\textures\expblue.pcx GROUP=Effects
#exec OBJ LOAD FILE=..\botpack\textures\ShockExplo.utx PACKAGE=WarEffects.ShockExplo

function MakeSound()
{
	PlaySound(Sound'WarEffects.General.Expl03',,12.0,,100);
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_Client )
		MakeSound();
	Super.PostBeginPlay();		
}

simulated function Timer()
{
}

defaultproperties
{
	NumFrames=15
	Pause=0.05
	LightType=8
	LightEffect=13
	LightBrightness=255
	LightRadius=6
	LightHue=27
	LightSaturation=71
	DrawType=7
	bCorona=false
	LifeSpan=0.7
	Texture=Texture'ShockExplo.asmdex_a00'
	DrawScale=1
	Skins=/* Array type was not detected. */
	Style=3
}