class B9_MenuPDA_Menu extends displayItem;

var class<B9_MenuPDA_Menu>		fReturnMenu;
var array<displayItem>			fDisplayItems;
var int							fFocusItem;
var Interactions.EInputKey		fKeyDown;
var B9_PDABase					fPDABase;
var float						fByeByeTicks;
var sound						fUpSound;
var sound						fDownSound;
var sound						fMouseOverSound;
var	sound						fClickSound;
var	sound						fCancelSound;
var float						fMenuSoundVolume;
var float						fRepeatTicks;
var bool						fUsesJoy3;
var bool						fUsesJoy4;

// For these states 0 means normal, -1 means it is not used (so Ghost the option) and 1 means it has just been used
var  int						fButtonXState;
var  int						fButtonYState;
var  int						fButtonAState;
var  int						fButtonBState;
var  int						fDefaultXState;
var  int						fDefaultYState;
var  int						fDefaultAState;
var  int						fDefaultBState;
var	 bool						fFailedToDrawAllItems;
var  int						fStartDrawingAtThisItem;
const kFocus_NoFocus = 0;
const kFocus_StandardFocus = 1;
const kFocus_SelectedFocus = 2;


function Setup( B9_PDABase pdaBase )
{
	fPDABase = pdaBase;		
}

function FullReset()
{
	PartialReset();
	fFocusItem = 0;
}

function PartialReset()
{
	fByeByeTicks = 0.0f;
	fRepeatTicks = 0;
	fKeyDown = IK_None;
	
	fButtonXState = fDefaultXState;
	fButtonYState = fDefaultYState;
	fButtonAState = fDefaultAState;
	fButtonBState = fDefaultBState;

}

function AddDisplayItem( displayItem item )
{
	item.Setup( fPDABase );
	fDisplayItems[ fDisplayItems.Length ] = item;
}

function bool handleKeyEvent(Interactions.EInputKey KeyIn,out Interactions.EInputAction Action, float Delta)
{
	
	local Pawn pawn, oldPawn;
	local bool hasbeenHandled;
	local int numItems;
	local Interaction.EInputKey Key;

	numItems = fDisplayItems.length;
	hasbeenHandled = false;
	// Do handling here


	Key = fPDABase.ConvertJoystick(KeyIn);

	if( fFocusItem >= 0 )
	{
		hasbeenHandled = fDisplayItems[fFocusItem].handleKeyEvent(KeyIn, Action ,Delta);
	}

	if (fByeByeTicks == 0.0f && hasbeenHandled == false)
	{
		if( Action == IST_Press && fButtonAState == 0 && (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
			Key == IK_Joy1) )
		{
//			log("Enter");
			fKeyDown = IK_Enter;
			fButtonAState = 1;
			ClickItem();
			fPDABase.RootController.PlaySound( fClickSound,, fMenuSoundVolume );
		}
		else if(  Action == IST_Press && fButtonBState == 0 && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
//			log("BackSpace");
			fKeyDown = IK_Backspace;
			fButtonBState = 1;
			fPDABase.RootController.PlaySound( fCancelSound,, fMenuSoundVolume );
			BeginByeByeTimer();
		}
		if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
			Key == IK_Joy1) )
		{
			fButtonAState = 0;
			if( fKeyDown == IK_Enter || fKeyDown == IK_Space)
			{
				fKeyDown = IK_None;
			}
		}
		if( Action == IST_Release && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			fButtonBState = 0;
			if( fKeyDown == IK_Enter || fKeyDown == IK_Space)
			{
				fKeyDown = IK_None;
			}
		}

		else if ( Key == IK_Joy3 )
		{
			// Must be filled out in the custom menu
			if( fButtonXState == 0 )
			{
				fButtonXState = 1;
			}
		}else if (Key == IK_Joy4 )
		{
			if( fButtonYState == 0 )
			{
				fButtonYState = 1;
			}
			// Must be filled out in the custom menu
		}
		else if (/*fPDABase.bDrawMouse &&*/ (Key == IK_MouseX || Key == IK_MouseY))
		{
			HighlightByMouse(); 
		}
		else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_None)
			{
				SelectItem((fFocusItem - 1) , 0.50f);
				fKeyDown = IK_Up;
				fPDABase.RootController.PlaySound( fUpSound,, fMenuSoundVolume ); 	
			}
		}
		else if( Action == IST_Release && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_Up)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_None)
			{
				SelectItem((fFocusItem + 1) , 0.5f);
				fKeyDown = IK_Down;
				fPDABase.RootController.PlaySound( fDownSound,, fMenuSoundVolume );	
			}
		}
		else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_Down)
				fKeyDown = IK_None;
		}else
		{
			hasbeenHandled = false;
		}
	}
	else
	{
		hasbeenHandled = false;
	}

	// End Handling

/*	dferrellNF
	if( hasbeenHandled == false )
	{
		hasbeenHandled = fDisplayItems[fFocusItem].handleKeyEvent(KeyIn, Action ,Delta);
	}
*/
	return hasbeenHandled;
}
// Does not apear to be called :(
function Think( canvas Canvas )
{

}

function HighlightByMouse()
{
	local int index;
	index = FindItemUnderMouse();
	if( index >= 0 && fDisplayItems[index].fCanAcceptFocus )
	{
		fFocusItem = index;	
		fPDABase.RootController.PlaySound( fMouseOverSound,, fMenuSoundVolume );
	}
}
function int FindItemUnderMouse()
{
	local int index;
	for (index=0;index<fDisplayItems.Length;index++)
	{
//		log("Trying to Find item Under mouse at X:"$fPDABase.MouseX$"Y:"$fPDABase.MouseY);
		if( fDisplayItems[index].IsOver(fPDABase.MouseX,fPDABase.MouseY) )
		{
			return index;
		}
	}
	return -1; //The mouse is over no items
}

function ClickItem(optional B9_MenuPDA_Menu menu)
{
	// We ignore the menu input because this is a menu.
	if( fFocusItem >= 0 )
	{
		fDisplayItems[fFocusItem].ClickItem(Self);
	}
}
// Setting this to zero will set this to the true default value of .5 seconds
function BeginByeByeTimer(optional float seconds )
{
	if( seconds == 0.0f )
	{
		seconds = 0.5f;
	}
	fByeByeTicks = seconds;
}

function UpdateMenu( float Delta )
{
	local bool change;
	local int numItems;

	numItems = fDisplayItems.length;

	if (fByeByeTicks > 0)
	{
		fByeByeTicks -= Delta;
		if (fByeByeTicks <= 0.0f)
		{
			if (fKeyDown == IK_Enter)
			{
				if( fFocusItem >= 0 )
					fDisplayItems[fFocusItem].ActOnClick(fPDABase, fReturnMenu );
			}
			else
			{
				fPDABase.AddMenu(fReturnMenu);
			}
		}

		return;
	}

	change = false;

	if (fKeyDown != IK_None)
	{
		fRepeatTicks -= Delta;
//		log("Post Key Press Repeat Ticks set to "$fRepeatTicks);
		if (fRepeatTicks <= 0.0f)
		{
			change = true;
			fRepeatTicks = 1.0;
		}

		if (change)
		{
			if (fKeyDown == IK_Up)
			{
				SelectItem((fFocusItem - 1) , 1.5f);
				fPDABase.RootController.PlaySound( fUpSound,, fMenuSoundVolume );
			}
			else if (fKeyDown == IK_Down)
			{

				SelectItem((fFocusItem + 1) , 1.5f);
				fPDABase.RootController.PlaySound( fDownSound,, fMenuSoundVolume );
			}
		}
	}
	else if (fRepeatTicks > 0.0f)
	{
		fRepeatTicks -= Delta;
		if (fRepeatTicks < 0.0f)
			fRepeatTicks = 0.0f;
	}
}


	
	// fDisplayItems
function PostRender( canvas Canvas )
{
	local int focus;
	local int beginPoint_X;
	local int beginPoint_Y;
	local int endPoint_X;
	local int endPoint_Y;
	local int i;

	fFailedToDrawAllItems = false;
	beginPoint_X	= fPDABase.fBeginPoint_X;
	beginPoint_Y	= fPDABase.fBeginPoint_Y;
	endPoint_X		= fPDABase.fEndPoint_X;
	endPoint_Y		= fPDABase.fEndPoint_Y;;
	
	Canvas.CurX  =  beginPoint_X;
	Canvas.CurY  =  beginPoint_Y;
	
//	log("Start Menu Draw");
	// If the item can not have focus, find one that can!
	if( fFocusItem >= 0 && fDisplayItems.length > 2 && fDisplayItems[fFocusItem].fCanAcceptFocus == false)
	{
		SelectItem(fFocusItem+1,0);
	}
 // Tell the Items to draw themselves
	for (i=fStartDrawingAtThisItem;i<fDisplayItems.Length;i++)
	{

		if ( i == fFocusItem )
		{
			if (fByeByeTicks > 0 && fKeyDown == IK_Enter)
			{
				focus = kFocus_SelectedFocus;
			}else
			{
				focus = kFocus_StandardFocus;
			}
		}else
		{
			focus = kFocus_NoFocus;
		}
//		log("Begin and End Points");
//		log("("$beginPoint_X$","$beginPoint_Y$") ("$endPoint_X$","$endPoint_Y$")");
		if( fDisplayItems[i].Draw( Canvas, focus, beginPoint_X,beginPoint_Y,endPoint_X, endPoint_Y, fPDABase) == false )
		{
		//	log("Failed to Draw Item"$i$":"$fDisplayItems[i].fProcessedLabel[0] );
			fFailedToDrawAllItems = true;
		}
	}

}

function SelectItem( int n, float ticks )
{
	local bool Next;
	local int nextSelection;
	local int numberOfTries;

	nextSelection = n;
	if( nextSelection > (fDisplayItems.length - 1) )
	{ 
		nextSelection = 0;
	}else if ( nextSelection < 0 )
	{
		nextSelection = fDisplayItems.length - 1;
	}
//	Log("SelectItem called with "$n);
	if( fFocusItem <= n )
	{
		Next = true;
	}else
	{
		Next = false;
	}
//	Log("Next is "$Next);
	numberOfTries = 0;
	while ( fDisplayItems[nextSelection].fCanAcceptFocus == false && numberOfTries < fDisplayItems.length )
	{
//		log("Next is "$Next$"Current Attempt that failed is "$nextSelection);
		if( Next == true )
		{
			nextSelection = nextSelection + 1;// Skip to the next
		}else
		{
			nextSelection = nextSelection - 1;// Previous item
		}
		if( nextSelection > (fDisplayItems.length - 1) )
		{ 
			nextSelection = 0;
		}else if ( nextSelection < 0 )
		{
			nextSelection = fDisplayItems.length - 1;
		}
		numberOfTries++;
//		log("Next Attempt is "$nextSelection);
	}

//	Log("NumberOfTries is "$numberOfTries$"NumberofDisplayItems is "$fDisplayItems.length);
	if( numberOfTries >= fDisplayItems.length )
	{
//		log("We tried them all, so there must be no focus items so we set it to -1");
		fFocusItem = -1;
	}else
	{
		fFocusItem = nextSelection;
	}
	fRepeatTicks = ticks;
//	log("Repeat Ticks set to "$fRepeatTicks);

}

function displayItem AddGenericMenu(string Label)
{
	local int indexpoint;

	indexpoint = fDisplayItems.length;

	fDisplayItems.Insert(fDisplayItems.length,1);
	fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
	fDisplayItems[indexpoint].fLabel		= Label;
	return fDisplayItems[indexpoint];
}

function displayItem AddSimpleDisplayItem(string Label)
{
	local int indexpoint;
	indexpoint = fDisplayItems.length;
	fDisplayItems.Insert(fDisplayItems.length,1);
	fDisplayItems[indexpoint]					= new(None)class'displayitem';
	fDisplayItems[indexpoint].fLabel			= Label;
	fDisplayItems[indexpoint].fCanAcceptFocus	= false;
	return fDisplayItems[indexpoint];
}

function string MapSpecialChars(string URN)
{
	local int nIndex;
	local string Result;

	while(true)
	{
		nIndex = InStr(URN, " ");
		if(nIndex < 0)
		{
			Result = Result $ URN;
			break;
		}

		Result = Result $ Left(URN, nIndex) $ "%20";
		URN = Right(URN, Len(URN) - nIndex - 1);
	}

	return Result;
}

function QuerryButtonOptions(out int ButtonX,out int ButtonY,out int ButtonA, out int ButtonB)
{
	// Temp Flash code
	ButtonX = fButtonXState;
	ButtonY = fButtonYState;
	ButtonA = fButtonAState;
	ButtonB = fButtonBState;
}

defaultproperties
{
	fUpSound=Sound'B9Interface_sounds.menus.menu_beep09'
	fDownSound=Sound'B9Interface_sounds.menus.menu_beep06'
	fMouseOverSound=Sound'B9Interface_sounds.menus.menu_beep02'
	fClickSound=Sound'B9Interface_sounds.menus.menu_beep10'
	fCancelSound=Sound'B9Interface_sounds.menus.menu_beep04'
	fMenuSoundVolume=0.5
	fDefaultXState=-1
	fDefaultYState=-1
}