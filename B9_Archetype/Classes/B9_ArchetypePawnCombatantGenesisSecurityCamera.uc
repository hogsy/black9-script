//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis spider bot.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisSecurityCamera extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters

defaultproperties
{
	fCharacterMaxHealth=100
	bCanJump=false
	bCanWalk=false
	bCanSwim=false
	bCanClimbLadders=false
	bCanStrafe=false
	GroundSpeed=0
	WaterSpeed=0
	BaseEyeHeight=0
	EyeHeight=0
	Health=100
	MenuName="B9_CombatantSecurityCamera"
	ControllerClass=Class'B9Creatures.B9_MonsterControllerImmobileDetector'
	bPhysicsAnimUpdate=false
	Physics=0
	Mesh=SkeletalMesh'B9Pickups_models.Duffel_Bag'
	CollisionRadius=50
	CollisionHeight=25
	Buoyancy=100
}