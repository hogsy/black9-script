class displayitem_AcceptSP extends displayItem;

var B9_PDABase	fPDA;
var B9_PDA_SinglePlayerCharacterSelect.tPlayerInfo fPlayerInfo;

function Setup( B9_PDABase pdaBase )
{
	fPDA = pdaBase;	
}

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}

// This is the function that is called when the displayitem is selected only if fbStartByeByeTImerOnClick is true
function ActOnClick( out B9_PDABase PDA, optional class<B9_MenuPDA_Menu> returnMenuClass )
{
	fPDA.AddMenu( class'B9_PDA_Loading', None );
	SetupPawn();
	fPDA.RootController.ClientTravel( "e1hq" $ "?Class=" $ fPlayerInfo.fPawnType, TRAVEL_Absolute, true );
	
	return;
}

function SetupPawn()
{
	local B9_PlayerPawn pawn;
	local Pawn oldPawn;
	local int i;
	local Inventory Inv;
	local vector loc;
	local Actor A;
	
	ForEach fPDA.RootController.AllActors( class'Actor', A )
	{
		if ( A.Name == 'LookTarget0' )
		{
			loc = A.location;
			break;
		}
	}

	pawn = B9_PlayerPawn( fPDA.RootController.spawn( fPlayerInfo.fPawnType, , , loc ) );		
	if ( pawn != None )
	{
		if ( fPDA.RootController.pawn != None )
		{
			oldPawn = fPDA.RootController.pawn;
			fPDA.RootController.UnPossess();
			oldPawn.Destroy();
		}

		fPDA.RootController.Possess( pawn );
	}
	else
		Log( "MMenu: Failed to create pawn" );
	
	
	pawn.fCharacterBaseStrength		= fPlayerInfo.fStr;
	pawn.fCharacterBaseAgility		= fPlayerInfo.fAgil;
	pawn.fCharacterBaseDexterity	= fPlayerInfo.fDex;
	pawn.fCharacterBaseConstitution	= fPlayerInfo.fCon;
	pawn.fCharacterName				= fPlayerInfo.fName;
	
	// Gain the Default items/skills if we don't have it already
	for(i=0;i<30;i++)
	{
		if( fPlayerInfo.fDefaultItemClasses[i] != None )
		{
			if ( pawn.FindInventoryType( fPlayerInfo.fDefaultItemClasses[i] ) == None )
			{
 				Inv = fPDA.RootController.Spawn( fPlayerInfo.fDefaultItemClasses[i] );
 				Inv.GiveTo( pawn );
			}
		}
	}

	pawn.ApplyModifications();
}


