//=============================================================================
// B9_CharMod
//
// Character Modification
//
// 
//=============================================================================

Class B9_CharMod extends Inventory
	abstract;
//    Native
//    NativeReplication;
 

var int					fPriority;			// We will insert each new modification in the modification list based on priority.  This will allow us to calculate spell effects in the correct order
var travel int			fStrength;			// Strength or current level of modification we could call this fLevel

replication
{
	reliable if (bNetDirty && ROLE==ROLE_Authority)
		fStrength;
}


// Functions 

function ModifyAttributes( B9_AdvancedPawn pawn );
function UnModifyAttributes( B9_AdvancedPawn pawn );

// These will be used to replace existing Unreal Pawn functions

function PawnTick( Pawn pawn, float deltaTime );


          
