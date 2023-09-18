//=============================================================================
// Effects, the base class of all gratuitous special effects.
// 
//=============================================================================
class Effects extends Actor;

var() sound 	EffectSound1;	// Added:  Sean C. Dumas/Taldren

defaultproperties
{
	bNetTemporary=true
	bNetInitialRotation=true
	RemoteRole=0
	bUnlit=true
	bGameRelevant=true
	CollisionRadius=0
	CollisionHeight=0
}