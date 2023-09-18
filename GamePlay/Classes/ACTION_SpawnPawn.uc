class ACTION_SpawnPawn extends ScriptedAction;

var(Action)		class<Pawn>	PawnClass;
var(Action)		vector			LocationOffset;
var(Action)		rotator			RotationOffset;
var(Action)		bool			bOffsetFromScriptedPawn;
var(Action)		name			PawnTag;
var(Action)		name			fAIScriptTag;
var(Action)		string		fStartingWeaponString;
var(Action)		bool		fStartingWeaponHidden;
var(Action)		float		fFiringRate;
var(Action)		class<Pickup>	fDropItem1;
var(Action)		class<Pickup>	fDropItem2;
var(Action)		class<Pickup>	fDropItem3;

function bool InitActionFor(ScriptedController C)
{
	local vector loc;
	local rotator rot;
	local Pawn a;
//////////////////////////////////////////
// X. Tan, Taldren, 5/27/03
// Remove src of warning 
//	local Controller botCont;
//	local class<Weapon> WeaponClass;
//	local Weapon NewWeapon;
// End Modification
/////////////////////////


	if ( bOffsetFromScriptedPawn )
	{
		loc = C.Pawn.Location + LocationOffset;
		rot = C.Pawn.Rotation + RotationOffset;
	}
	else
	{
		loc = C.SequenceScript.Location + LocationOffset;
		rot = C.SequenceScript.Rotation + RotationOffset;
	}
	a = C.Spawn(PawnClass, ,,loc,rot);
	if (a == None)
		return false;

	// Assign Weapon
	// XT: Added NULL string check 05/11/03
	// UNDONE: why is it empty or "None" at the first place???
	if( fStartingWeaponString != "" && fStartingWeaponString != "None" )
	{
		a.Controller.EquipCombatItemByString( fStartingWeaponString, fStartingWeaponHidden );
	}
	
	// Assign firing rate
	a.SetFiringRate( fFiringRate );

	// Assign what Items will drop from this AI when it is killed.
	a.SetDropItems( fDropItem1, fDropItem2, fDropItem3 );

	a.Instigator = C.Pawn;
	if ( PawnTag != 'None' )
		a.Tag = PawnTag;

	if( fAIScriptTag != 'None' )
	{
		a.AIScriptTag = fAIScriptTag;
	}

	return false;	
}

function string GetActionString()
{
	return ActionString@PawnClass;
}

defaultproperties
{
	fFiringRate=0.5
	ActionString="Spawn Pawn"
}