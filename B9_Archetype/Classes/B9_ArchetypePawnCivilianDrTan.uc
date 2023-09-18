//////////////////////////////////////////////////////////////////////////
//
// Black 9 Dr Tan Archetype Pawn Class
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCivilianDrTan extends B9_ArchetypeCivilianPawn;

// Load the animations package for the Dr Tan archetype
#exec OBJ LOAD FILE=..\animations\B9_TDS_Characters.ukx PACKAGE=B9_TDS_Characters

simulated function AnimateIdle()
{
	MovementAnims[ 0 ]='idle';
	MovementAnims[ 1 ]='idle';
	MovementAnims[ 2 ]='idle';
	MovementAnims[ 3 ]='idle';
}

simulated function AnimateSearching()
{
	MovementAnims[ 0 ]='search';
	MovementAnims[ 1 ]='search';
	MovementAnims[ 2 ]='search';
	MovementAnims[ 3 ]='search';
}

defaultproperties
{
	fPawnName="Dr. Tan"
	MenuName="B9_DrTan"
	ControllerClass=Class'B9_AI_ControllerCivilianDrTan'
	Mesh=SkeletalMesh'B9_TDS_Characters.Dr_Tan_mesh'
}