//=============================================================================
// B9_SocketUseTrigger.uc
//
// A use trigger that will only fire its event if the user of the trigger
// posesses the correct item.
//
//=============================================================================


class B9_SocketUseTrigger extends UseTrigger;


var(SocketUseTrigger) Name		KeyItemTag;
var(SocketUseTrigger) Sound		SuccessSound;
var(SocketUseTrigger) Sound		FailureSound;


function UsedBy( Pawn user )
{
	if( CheckItem( user ) )
	{
		if( SuccessSound != None )
		{
			PlaySound( SuccessSound  );
		}

        TriggerEvent(Event, self, user);
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
		if( Inv.Tag == KeyItemTag || Inv.Tag == 'B9_UniversalSocketKey' )
		{
			return true;
		}
	}

	return false;
}



