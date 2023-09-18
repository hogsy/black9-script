class  displayitem_DisplayHostSkirmishOptions extends displayItem;

var class<B9_MenuPDA_Menu> fNextMenuName;
var B9MP_ServerDescription fCurrentServerDescription;
var int	fValueToDisplay;

/*
	fValueToChange & fValueToDisplay values
	0	kMyServersMinNumberofPlayers,
	1	kMyServersMaxNumberofPlayers,
	2	kMyServersMinCharacterLevel,
	3	kMyServersMaxCharacterLevel,
	4	kMyServersCombatantGroup1,
	5	kMyServersCombatantGroup2,
	6	kMyServersIsAPrivateGame,
	7	kMyServersIsARankedGame,
	8	kMyServersGameType,
	9	kMyServersDetailedMapList,
	10	kMyServersCreateGame
*/

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}
function bool Draw(canvas Canvas, int focus, int beginPoint_X, int beginPoint_Y,int endPoint_X, int endPoint_Y, out B9_PDABase PDA)
{
	if( fValueToDisplay == 0 )
	{
		fLabel = "" $ fCurrentServerDescription.fInfo.fMinPlayers;
	}
	else if( fValueToDisplay == 1 )
	{
		fLabel = "" $ fCurrentServerDescription.fInfo.fMaxPlayers;
	}
	else if( fValueToDisplay == 2 )
	{
		fLabel = "" $ fCurrentServerDescription.fInfo.fMinCharacterLevel;
	}
	else if( fValueToDisplay == 3 )
	{
		fLabel = "" $ fCurrentServerDescription.fInfo.fMaxCharacterLevel;
	}
	else if( fValueToDisplay == 6 )
	{
		if( fCurrentServerDescription.fInfo.fPrivate == false )
		{
			fLabel = " N";
		}
		else
		{
			fLabel = " Y";		
		}
	}
	else if( fValueToDisplay == 7 )
	{
		if( fCurrentServerDescription.fInfo.fRanked == false )
		{
			fLabel = " N";
		}
		else
		{
			fLabel = " Y";		
		}
	}					
		
	return Super.Draw(Canvas, focus, beginPoint_X, beginPoint_Y,endPoint_X, endPoint_Y, PDA);
}
function ClickItem(optional B9_MenuPDA_Menu menu)
{
	Super.ClickItem( menu );
}

// This is the function that is called when the displayitem is selected only if fbStartByeByeTImerOnClick is true
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
	if( fValueToDisplay == 10 )
	{
		PDA.AddMenu( class'B9_PDA_NameYourServerMenu', class'B9_PDA_HostSkirmishOptionsMenu' );
	}	

	return;
}
defaultproperties
{
	fbStartByeByeTImerOnClick=false
}