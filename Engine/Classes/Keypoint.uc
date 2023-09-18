//=============================================================================
// Keypoint, the base class of invisible actors which mark things.
//=============================================================================
class Keypoint extends Actor
	abstract
	placeable
	native;

// Sprite.
#exec Texture Import File=Textures\Keypoint.pcx Name=S_Keypoint Mips=Off MASKED=1

defaultproperties
{
	bStatic=true
	bHidden=true
	Texture=Texture'S_Keypoint'
	SoundVolume=0
	CollisionRadius=10
	CollisionHeight=10
}