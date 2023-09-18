class WarDecoration extends Decoration
	abstract;

/* This is the superclass of non-static decorations which interact with players and
the world.
Static Decorations should be subclassed directly from Engine.Decoration
*/

#exec AUDIO IMPORT FILE="..\botpack\sounds\general\bPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="..\botpack\sounds\general\EndPush.wav" NAME="Endpush" GROUP="General"

defaultproperties
{
	bPushable=true
	bDamageable=true
	PushSound=Sound'General.ObjectPush'
	EndPushSound=Sound'General.Endpush'
	Health=30
	bStatic=false
	CollisionRadius=24
	CollisionHeight=29
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
	bBlockPlayers=true
	Mass=50
	Buoyancy=40
}