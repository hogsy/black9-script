class ACTION_SpawnRagdoll extends ScriptedAction;

var(Action)		name			ActorTag;
var(Action)		name			HitBoneName;
var(Action)		vector			HitBoneImpulse;
var(Action)		vector			InitialVel;
var(Action)		float			Friction;
var(Action)		float			LinDamping;
var(Action)		float			AngDamping;

function bool InitActionFor(ScriptedController C)
{
	local actor a;

	a = C.Spawn(class'KRagDoll',,, C.SequenceScript.Location, C.SequenceScript.Rotation);
	a.Instigator = C.Pawn;
	if ( ActorTag != 'None' )
		a.Tag = ActorTag;

	a.KSetFriction(Friction);
	a.KSetDampingProps(LinDamping, AngDamping);

	// If a bone has been named to be hit with an impulse, do it here
	// otherwise, just wake up physics.
	if(HitBoneName != 'None')
		a.KAddImpulse(HitBoneImpulse, vect(0, 0, 0), HitBoneName);
	else
		a.KWake();

	a.KSetSkelVel(InitialVel);

	return false;
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	LinDamping=0.2
	AngDamping=0.2
	ActionString="Spawn ragdoll"
}