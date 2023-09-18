//=============================================================================
// B9_AutomationPart
//
// 
//	The pieces that make up the automation
// 
//=============================================================================



class B9_AutomationPart extends Pawn
	abstract
	notplaceable;


//////////////////////////////////
// Definitions
//



//////////////////////////////////
// Variables
//
var B9_Automation fParent;


//////////////////////////////////
// Functions
//

function SetParent( B9_Automation parent )
{
	fParent = parent;
}


//////////////////////////////////
// States
//



//////////////////////////////////
// Initialization
//
defaultproperties
{
	ControllerClass=none
	Physics=5
	bActorShadows=false
	bInterpolating=true
}