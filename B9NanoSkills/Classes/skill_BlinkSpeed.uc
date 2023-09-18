//=============================================================================
// skill_BlinkSpeed
//
// Character Modification
// Allows players to teleport forward 10 - 20 feet, but not through walls.
// 
//=============================================================================

Class skill_BlinkSpeed extends B9_Skill;
//    Native
//    NativeReplication;
 

// Functions 

function PawnTick( Pawn pawn, float deltaTime )
{
}

defaultproperties
{
	fSkillName="BlinkSpeed"
	fPriority=1
	fStrength=10
}