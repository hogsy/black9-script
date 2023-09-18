//=============================================================================
// DummyMod
//
// Character Modification
//
// 
//=============================================================================

Class DummyMod extends B9_BodyMod;
//    Native
//    NativeReplication;
 

// Functions 

function ModifyAttributes( B9_AdvancedPawn pawn )
{
	pawn.fCharacterStrength += fStrength;
}

function UnModifyAttributes( B9_AdvancedPawn pawn )
{
	pawn.fCharacterStrength -= fStrength;
}

function PawnTick( Pawn pawn, float deltaTime )
{
}


          
defaultproperties
{
	fBodyModName="Dummy Mod"
	fPriority=1
	fStrength=10
}