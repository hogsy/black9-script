class B9_PDA_Cheats_Map extends B9_MenuPDA_Menu;

var protected Array<string> fMaps;
function bringInMaps()
{
	fMaps[0] =  " M06A01";
	fMaps[1] =  " M06A02";
	fMaps[2] =  " M06A03";
	fMaps[3] =  " M06A08";
	fMaps[4] =  " M06A10";
	fMaps[5] =  " M06A11";
	fMaps[6] =  " M06A13";
	fMaps[7] =  " M06A14";
	fMaps[8] =  " M09A01";
	fMaps[9] =  " M09A02";
	fMaps[10] =  " M09A03";
	fMaps[11] =  " M09A04";
	fMaps[12] =  " M09A05";
	fMaps[13] =  " M13A01";
	fMaps[14] =  " M13A02";
	fMaps[15] =  " M13A03";
	fMaps[16] =  " M13A04";
	fMaps[17] =  " M02A01";
	fMaps[18] =  " M02A02";
	fMaps[19] =  " M02A03";
	fMaps[20] =  " M02A04";
	fMaps[21] =  " M02A05";
	fMaps[22] =  " M08A01";
	fMaps[23] =  " M08A02";
	fMaps[24] =  " M08A03";
	fMaps[25] =  " M08A04";
}
function bool handleKeyEvent(Interactions.EInputKey KeyIn,out Interactions.EInputAction Action, float Delta)
{
	local Interaction.EInputKey Key;
	Key = fPDABase.ConvertJoystick(KeyIn);

	if (fByeByeTicks == 0.0f)
	{
		if ( Key == IK_Joy3 )
		{
			// Must be filled out in the custom menu
		}else if (Key == IK_Joy4 )
		{
			// Must be filled out in the custom menu
		}else
		{
			return Super.handleKeyEvent( KeyIn , Action , Delta );
		}
	}
	return false;

}

function Setup( B9_PDABase pdaBase )
{
	local int i;
	local displayItem newItem;

	bringInMaps();

log("fMaps.Length=" $ fMaps.Length );
	for( i=0; i < fMaps.Length; ++i )
	{
		newItem = new(None)class'displayItem';
		newItem.fLabel = fMaps[i];
		newItem.fDrawNextItemTotheRight=true;
		newItem.fEventParent = self;
		newItem.fEventID = i;
		
		if( i % 4 == 0 && i != 0 )
			newItem.fDrawNextItemTotheRight=false;
		
		AddDisplayItem( newItem );
	}
}

function ChildEvent( displayItem item, int id )
{
	GoToMap( fMaps[id] );
}

function GoToMap( String mapName )
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "clienttravel " $ mapName  );
}


function Initialize()
{
	//Don't do anything requiring controllers here!
}
