//=============================================================================
// AnimSpriteEffect.
//=============================================================================
class AnimSpriteEffect extends Effects;

var() texture SpriteAnim[20];
var() int NumFrames;
var() float Pause;
var int i;
var Float AnimTime;

defaultproperties
{
	LightType=1
	LightBrightness=199
	LightRadius=20
	LightHue=24
	LightSaturation=115
	bCorona=true
	bDynamicLight=true
	DrawScale=0.3
}