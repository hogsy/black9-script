class AnimNotify_Effect extends AnimNotify
	native;

var() class<Actor> EffectClass;
var() name Bone;
var() vector OffsetLocation;
var() rotator OffsetRotation;
var() bool Attach;
var() name Tag;
var() float DrawScale;
var() vector DrawScale3D;

var private transient Actor LastSpawnedEffect;	// Valid only in the editor.

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
	DrawScale=1
	DrawScale3D=(X=1,Y=1,Z=1)
}