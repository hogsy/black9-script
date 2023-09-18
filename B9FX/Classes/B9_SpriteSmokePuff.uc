//=============================================================================
// B9_spritesmokepuff.
//=============================================================================
class B9_SpriteSmokePuff extends AnimSpriteEffect;

var() Texture SSprites[4];
var() float RisingRate;
var() int NumSets;
	
simulated function BeginPlay()
{
	Velocity = Vect(0,0,1)*RisingRate;
	if ( !Level.bDropDetail )
		Texture = SSPrites[Rand(NumSets)];
}

defaultproperties
{
	SSprites[0]=Texture'WarEffects.utsmoke.us1_a00'
	SSprites[1]=Texture'WarEffects.utsmoke.us2_a00'
	SSprites[2]=Texture'WarEffects.utsmoke.US3_A00'
	SSprites[3]=Texture'WarEffects.utsmoke.us8_a00'
	RisingRate=50
	NumSets=4
	NumFrames=8
	Pause=0.05
	LightType=0
	LightBrightness=10
	LightRadius=7
	LightHue=0
	LightSaturation=255
	Physics=6
	DrawType=7
	bCorona=false
	bDynamicLight=false
	RemoteRole=2
	LifeSpan=1.5
	Texture=Texture'WarEffects.utsmoke.us1_a00'
	DrawScale=2
	Style=3
}