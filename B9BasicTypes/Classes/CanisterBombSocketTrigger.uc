//=============================================================================
// CanisterBombSocketTrigger.uc
//
//=============================================================================


class CanisterBombSocketTrigger extends B9_SocketUseTrigger;

var bool	fBombPlaced;
var bool	fCorrespondingPanelHacked;

function UsedBy( Pawn user )
{
	if( CheckItem( user ) )
	{
		if(!fBombPlaced)
		{
			if( SuccessSound != None )
			{
				PlaySound( SuccessSound  );
			}
			fBombPlaced = true;
			TriggerEvent(Event, self, user);
		}
	}
	else
	{
		if( FailureSound != None )
		{
			PlaySound( FailureSound  );
		}
	}
}

simulated function bool CheckItem( Pawn P )
{
	local Inventory Inv;

	for( Inv = P.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		if( Inv.IsA( 'B9_CanisterBomb' ) )
		{
			P.DeleteInventory( Inv );
			return true;
		}
	}

	return false;
}




