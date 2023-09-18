class B9_PDA_InfoStiks extends B9_MenuPDA_Menu;

var localized string fLabelNone;
var color	CompleteTextColor;
var color	CompleteFocusTextColor;
var bool bInit;
var bool bUnPauseOnce;

function bool handleKeyEvent(Interactions.EInputKey KeyIn,out Interactions.EInputAction Action, float Delta)
{
	local Interaction.EInputKey Key;
	Key = fPDABase.ConvertJoystick(KeyIn);

	if (fByeByeTicks == 0.0f)
	{
		if ( Key == IK_Joy3 )
		{
			// Must be filled out in the custom menu
		}
		else if (Key == IK_Joy4 )
		{
			// Must be filled out in the custom menu
		}
/*		else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_None && (fStartDrawingAtThisItem != 0 ))
			{
				fStartDrawingAtThisItem = fStartDrawingAtThisItem - 1;
				if( fStartDrawingAtThisItem <= 0 )
				{
					fStartDrawingAtThisItem = 0;
				}				
				fKeyDown = IK_Up;
				fPDABase.RootController.PlaySound( fUpSound ); 	
			}
		}
		else if( Action == IST_Release && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_Up)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_None && fFailedToDrawAllItems == true)
			{
				fStartDrawingAtThisItem = fStartDrawingAtThisItem + 1;
				if( fStartDrawingAtThisItem >= (fDisplayItems.Length - 1) )
				{
					fStartDrawingAtThisItem = (fDisplayItems.Length - 1);
				}
				fKeyDown = IK_Down;
				fPDABase.RootController.PlaySound( fDownSound );	
			}
		}
		else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_Down)
				fKeyDown = IK_None;
		} */
		else
		{
			return Super.handleKeyEvent( KeyIn , Action , Delta );
		}
	}
	return false;

}

function ListChanged()
{
	bInit = false;
	fDisplayItems.Length = 0;
}

function UpdateMenu( float Delta )
{
	local int indexpoint;
	local B9_BasicPlayerPawn Pawn;
	local Inventory Inv;
	local InfoStik Stik;

	Super.UpdateMenu( Delta );
	if( bInit == false )
	{
		bInit = true;

		Pawn = B9_BasicPlayerPawn(fPDABase.RootController.Pawn);
		if( Pawn != None )
		{
			indexpoint = 0;
			Inv = Pawn.Inventory;
			while (Inv != None)
			{
				Stik = InfoStik(Inv);
				if (Stik != None)
				{
					fDisplayItems.Insert(indexpoint,1);
					fDisplayItems[indexpoint]					= new(None)class'displayitem_GenericMenuItem';
					fDisplayItems[indexpoint].fLabel			= Stik.GetTitle();
					fDisplayItems[indexpoint].fCanAcceptFocus	= true;
					displayitem_GenericMenuItem(fDisplayItems[indexpoint]).fMenuClass = class'B9_PDA_InfoStikContents';

					++indexpoint;
				}

				Inv = Inv.Inventory;
			}
			if(indexpoint==0)
			{
				fDisplayItems.Insert(indexpoint,1);
				fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
				fDisplayItems[indexpoint].fLabel		= fLabelNone;
				fDisplayItems[indexpoint].fCanAcceptFocus	= false;
			}
		}
		fFocusItem = indexpoint - 1;
	}
}

function Initialize()
{
	//Don't do anything requiring controllers here!

}

defaultproperties
{
	fLabelNone="None"
	CompleteTextColor=(B=0,G=80,R=30,A=0)
	CompleteFocusTextColor=(B=110,G=128,R=110,A=0)
}