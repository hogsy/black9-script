//////////////////////////////////////////////////////////////////////////
//
// Black 9 Spawn combatant code.
//
//////////////////////////////////////////////////////////////////////////
class ACTION_SpawnArchetypePawnCombatant extends ScriptedAction;

var(Action)		class<B9_ArchetypePawnCombatant> PawnClass;
var(Action)		vector			LocationOffset;
var(Action)		rotator			RotationOffset;
var(Action)		bool			bOffsetFromScriptedPawn;
var(Action)		name			PawnTag;
var(Action)		name			fAIScriptTag;

var(Action)		string		fStartingWeaponString;
var(Action)		bool		fStartingWeaponHidden;

var(Action)		class<Pickup>	fDropItem1;
var(Action)		class<Pickup>	fDropItem2;
var(Action)		class<Pickup>	fDropItem3;

var(Action)		float			Alertness;
var(Action)		bool			bAdjacentZoneHearing;
var(Action)		bool			bAroundCornerHearing;
var(Action)		bool			bHostile;
var(Action)		bool			bIsSquadLeader;
var(Action)		bool			bLOSHearing;
var(Action)		bool			bMuffledHearing;
var(Action)		bool			bSameZoneHearing;
var(Action)		bool			fAggressiveInNumbers;
var(Action)		bool			fAlarmGuard;
var(Action)		bool			fCheatAlwaysSeesEnemy;
var(Action)		float			fCombatStyle;
var(Action)		B9_AdvancedPawn.EFaction		fFaction;
var(Action)		float			fFrequencyOnGivingUpEnemyPosition;
var(Action)		float			fPainMessageRadius;
var(Action)		B9_ArchetypePawnBase.EStartupStates	fStartupState;
var(Action)		bool			fWarnsAlliesAboutEnemies;
var(Action)		float			HearingThreshold;
var(Action)		float			PeripheralVision;
var(Action)		float			SightRadius;
var(Action)		name			SquadName;

var(Action)		bool			fJumpAtEnemy;
var(Action)		name			fPatrolName;
var(Action)		bool			fReturnToOrigPos;
var(Action)		bool			fSentry;
var(Action)		bool			fPsychicKnowPlayerPosition;
var(Action)		array< int >	fAlarmList;		


function bool InitActionFor(ScriptedController C)
{
	local vector loc;
	local rotator rot;
	local B9_ArchetypePawnCombatant a;

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
	// XT: Added NULL string check 05/11/03.  why is it None or empty or "None" at the first place???
	// MikeT: Because both of those are legitamite values for specifying no additional weapons other than the default.
	if( fStartingWeaponString != "" && fStartingWeaponString != "None" )
	{
		a.Controller.EquipCombatItemByString( fStartingWeaponString, fStartingWeaponHidden );
	}

	// Assign what Items will drop from this AI when it is killed.
	a.SetDropItems( fDropItem1, fDropItem2, fDropItem3 );

	a.Instigator = C.Pawn;
	if ( PawnTag != 'None' )
		a.Tag = PawnTag;

	if( fAIScriptTag != 'None' )
		a.AIScriptTag = fAIScriptTag;
		
	a.Alertness = Alertness;
	a.bAdjacentZoneHearing = bAdjacentZoneHearing;
	a.bAroundCornerHearing = bAroundCornerHearing;
	a.bHostile = bHostile;
	a.bIsSquadLeader = bIsSquadLeader;
	a.bLOSHearing = bLOSHearing;
	a.bMuffledHearing = bMuffledHearing;
	a.bSameZoneHearing = bSameZoneHearing;
	a.fAggressiveInNumbers = fAggressiveInNumbers;
	a.fAlarmGuard = fAlarmGuard;
	a.fCheatAlwaysSeesEnemy = fCheatAlwaysSeesEnemy;
	a.fFaction = fFaction;
	a.fFrequencyOnGivingUpEnemyPosition = fFrequencyOnGivingUpEnemyPosition;
	a.fPainMessageRadius = fPainMessageRadius;
	a.fStartupState = fStartupState;
	a.fWarnsAlliesAboutEnemies = fWarnsAlliesAboutEnemies;
	a.HearingThreshold = HearingThreshold;
	a.PeripheralVision = PeripheralVision;
	a.SightRadius = SightRadius;
	a.SquadName = SquadName;
	a.fJumpAtEnemy = fJumpAtEnemy;
	a.fPatrolName = fPatrolName;
	a.fReturnToOrigPos = fReturnToOrigPos;
	a.fSentry = fSentry;
	a.fCombatStyle = fCombatStyle;
	a.fAlarmList = fAlarmList;
	a.fPsychicKnowPlayerPosition = fPsychicKnowPlayerPosition;

	return false;	
}

function string GetActionString()
{
	return ActionString@PawnClass;
}

defaultproperties
{
	bAroundCornerHearing=true
	bHostile=true
	bLOSHearing=true
	bMuffledHearing=true
	fCombatStyle=1
	fFrequencyOnGivingUpEnemyPosition=5
	fPainMessageRadius=500
	fWarnsAlliesAboutEnemies=true
	HearingThreshold=2800
	SightRadius=12000
	SquadName=Squad
	fPatrolName=DefaultPatrol
	ActionString="Spawn Pawn"
}