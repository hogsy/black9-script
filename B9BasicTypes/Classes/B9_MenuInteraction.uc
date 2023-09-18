/////////////////////////////////////////////////////////////
// B9_MenuInteraction
//

class B9_MenuInteraction extends Interaction;

#exec TEXTURE IMPORT NAME=MouseCursor FILE=Textures\MouseCursor.dds GROUP="Icons" ALPHA=1 MASKED=1 MIPS=OFF

var public transient PlayerController RootController;
var public transient B9_MenuInteraction RootInteraction;
var public transient B9_MenuInteraction ParentInteraction;
var public transient B9_MenuInteraction ChildInteraction;
var() localized string B9Fonts;

struct B9MouseCursor
{
	var Texture tex;
	var int HotX;
	var int HotY;
	var byte WindowsCursor;
};

var B9MouseCursor Cursor;
var B9MouseCursor ArrowCursor;
var float MouseX;
var float MouseY;
var float GUIScale;
var bool bDrawMouse;
var float OriginX;
var float OriginY;

var bool remapJoy;
var EInputKey remapJoyTable[16];

var name fMatineeTag;

/*
	XBOX:

	IK_Joy1			XGB_A
	IK_Joy2			XGB_B
	IK_Joy3			XGB_X 
	IK_Joy4			XGB_Y 
	IK_Joy5			XGB_Black 
	IK_Joy6			XGB_White 
	IK_Joy7			XGB_LeftTrigger 
	IK_Joy8			XGB_RightTrigger 
	IK_Joy9			XGB_DigitalUp 
	IK_Joy10		XGB_DigitalDown 
	IK_Joy11		XGB_DigitalLeft 
	IK_Joy12		XGB_DigitalRight 
	IK_Joy13		XGB_Start 
	IK_Joy14		XGB_Back 
	IK_Joy15		XGB_LeftThumb 
	IK_Joy16		XGB_RightThumb

	PS2:

	IK_Joy1			L1					IK_Joy6
	IK_Joy2			L2					IK_Joy7
	IK_Joy3			R1					IK_Joy5
	IK_Joy4			R2					IK_Joy8
	IK_Joy5			Triangle				IK_Joy4
	IK_Joy6			Square					IK_Joy3
	IK_Joy7			Circle					IK_Joy2
	IK_Joy8			Cross					IK_Joy1
	IK_Joy9			D-Pad Left				IK_Joy11
	IK_Joy10		D-Pad Right				IK_Joy12
	IK_Joy11		D-Pad Up				IK_Joy9
	IK_Joy12		D-Pad Down				IK_Joy10
	IK_Joy13		Left Analog Down (L3)			IK_Joy15
	IK_Joy14		Right Analog Down (R3)			IK_Joy16
	IK_Joy15		Select					IK_Joy14
	IK_Joy16		Start					IK_Joy13
*/

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	// base class does nothing here
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	RootInteraction = interaction;
	RootController = controller;
	ParentInteraction = parent;

	bDrawMouse = RootInteraction.bDrawMouse;

	if (Platform() == "PS2")
	{
		remapJoy = true;
		remapJoyTable[0] = IK_Joy6;
		remapJoyTable[1] = IK_Joy7;
		remapJoyTable[2] = IK_Joy5;
		remapJoyTable[3] = IK_Joy8;
		remapJoyTable[4] = IK_Joy4;
		remapJoyTable[5] = IK_Joy3;
		remapJoyTable[6] = IK_Joy2;
		remapJoyTable[7] = IK_Joy1;
		remapJoyTable[8] = IK_Joy11;
		remapJoyTable[9] = IK_Joy12;
		remapJoyTable[10] = IK_Joy9;
		remapJoyTable[11] = IK_Joy10;
		remapJoyTable[12] = IK_Joy15;
		remapJoyTable[13] = IK_Joy16;
		remapJoyTable[14] = IK_Joy14;
		remapJoyTable[15] = IK_Joy13;
	}

}

function EndMenu(B9_MenuInteraction interaction, int result)
{
	// general menu termination, called on ParentInteraction
}


// Override in the menu to allow actions when someone leaves a menu
function DeInitialize();


function SetOrigin(float orgX, float orgY)
{
	OriginX = orgX;
	OriginY = orgY;
}

function ActivateMouse()
{
	if (Platform() == "PC")
	{
		bDrawMouse = true;

		ArrowCursor.tex = texture'MouseCursor';
		ArrowCursor.HotX = 0;
		ArrowCursor.HotY = 0;
		ArrowCursor.WindowsCursor = ViewportOwner.IDC_ARROW;

		Cursor = ArrowCursor;
		GuiScale = 1;
		MouseX = 0;
		MouseY = 0;

		ViewportOwner.bShowWindowsMouse = true;
	}
}

function DeactivateMouse()
{
	ViewportOwner.bShowWindowsMouse = false;
}

function MakeChildInteraction(class<B9_MenuInteraction> NewInteractionClass)
{
	//local class<B9_MenuInteraction> NewInteractionClass;

	//NewInteractionClass = class<B9_MenuInteraction>(DynamicLoadObject(cname, class'Class'));
	if (NewInteractionClass != None)
	{
		ChildInteraction = new(None) NewInteractionClass;
		if (ChildInteraction != None)
		{
			ChildInteraction.Initialized();
			ChildInteraction.MenuInit(RootInteraction, RootController, self);
		}
	}
}

// This should probably be defigned elsewhere so that it can be used by other classes
function Rotator GetEularAngles( vector direction )
{
	local vector up, right;

	up = vect(0,0,1);
	right = up Cross direction;
	return OrthoRotation( direction, right, up );
}

// !!!! Temporarily joysticks without remapping:
// XBOX: A = IK_Joy1, B = IK_Joy2
// PS2:  <triangle> = IK_Joy8, <circle> = IK_Joy7
function EInputKey ConvertJoystick(EInputKey Key)
{
	local EInputKey NewKey;

	// !!!! XBOX only -- pass through
	if (!remapJoy || Key < IK_Joy1 || Key > IK_Joy16)
	{
		//Log("ConvertJoystick: No conversion, remap="$remapJoy);
		// In XBox IK_Joy14 is the same as IK-Joy2 
		if( Key == IK_Joy14 )
		{
			Key = IK_Joy2;
		}
		return Key;
	}

	NewKey = remapJoyTable[Key - IK_Joy1];
	//Log("ConvertJoystick: "$(Key - IK_Joy1 + 1)$" -> "$(NewKey - IK_Joy1 + 1));
	return NewKey;
}

function Think( canvas Canvas )
{
	if (ChildInteraction != None)
	{
		ChildInteraction.Think(Canvas);
	}
}

function Tick(float Delta)
{
	if (ChildInteraction != None)
	{
		ChildInteraction.Tick(Delta);
	}
}

function DrawTextWithShadow( canvas Canvas, string text, int x, int y, color fillHue, color shadowHue, optional int offset)
{
	if (offset == 0)
		offset = 1;

	// Canvas font is set in HUD.uc. They are
	// overloaded in B8HUD::PreBeginPlay. For
	// debug menu, because B8HUD::PreBeginPlay
	// is not called yet, it will stll use default
	// font
	//Canvas.Font = LoadFont( "SimSun20");

	Canvas.SetPos( x + offset, y + offset);
	Canvas.SetDrawColor(shadowHue.r, shadowHue.g, shadowHue.b);
	Canvas.DrawText( text, false );

	Canvas.SetPos( x, y);
	Canvas.SetDrawColor(fillHue.r, fillHue.g, fillHue.b);
	Canvas.DrawText( text, false );
}

/*
function font LoadFont( String fontName )
{
	return font( DynamicLoadObject(B9Fonts $ fontName, class'Font' ) );

	//local Font myFont;

	//myFont = font( DynamicLoadObject(B9Fonts $ fontName, class'Font' ) );

	//if ( myFont == None )
	//{
	//	Log( "SCDTemp/B9_MenuInteraction::LoadFont():No myFont,"$ B9Fonts $" ,"$ fontName  );
	//}
	//else
	//{
	//	Log( "SCDTemp/B9_MenuInteraction::LoadFont(): myFont is"$myFont.Name );
	//}
	
	//return myFont;
}

function font LoadFontEx( String fontName, int pitch )
{
	return font( DynamicLoadObject(B9Fonts $ fontName $ string( Pitch ), class'Font' ) );

	//local Font myFont;

	//myFont = font( DynamicLoadObject(B9Fonts $ fontName $ string( Pitch ), class'Font' ) );

	//if ( myFont == None )
	//{
	//	Log( "SCDTemp/B9_MenuInteraction::LoadFontEx():No myFont,"$ B9Fonts $" ,"$ fontName  );
	//}
	//else
	//{
	//	Log( "SCDTemp/B9_MenuInteraction::LoadFontEx(): myFont is"$myFont.Name );
	//}

	//return myFont;
}
*/

function SwitchToMatinee(name newMatineeTag)
{
	local SceneManager SM;

	if (RootInteraction.fMatineeTag != newMatineeTag)
	{
		if (RootInteraction.fMatineeTag != '')
		{
			foreach RootController.AllActors( class'SceneManager', SM )
			{
				if (SM.Tag == RootInteraction.fMatineeTag)
				{
					SM.CurrentTime = SM.TotalSceneTime + 1;
					SM.NextSceneTag = newMatineeTag;
					RootInteraction.fMatineeTag = newMatineeTag;
					return;
				}
			}
		}
/*
		if (newMatineeTag != '')
		{
			// start matinee
			foreach RootController.AllActors( class'SceneManager', SM )
			{
				if (SM.Tag == newMatineeTag)
				{
					SM.Trigger(RootController, None);
					RootInteraction.fMatineeTag = newMatineeTag;
					return;
				}
			}
		}
*/
	}
}

function ViewActor(name ActorName, name FromName)
{
	local Actor A, F;
	local bool ok;

	ok = false;
	ForEach RootController.AllActors(class'Actor', A)
		if ( A.Name == ActorName )
		{
			ok = true;
			break;
		}

	if (!ok) return;

	ForEach RootController.AllActors(class'Actor', F)
		if ( F.Name == FromName )
		{
			F.SetRotation(GetEularAngles(A.Location - F.Location));
			RootController.SetViewTarget(F);
			return;
		}
}


function MouseRender( canvas Canvas )
{
	if (RootInteraction.bDrawMouse)
	{
		RootInteraction.DrawMouse(Canvas);
	}
}

function PostRender( canvas Canvas )
{
	if (ChildInteraction != None)
	{
		ChildInteraction.PostRender(Canvas);
	}
}

function DrawMouse(Canvas C) 
{
	local float x, y;

	if (ViewportOwner != None && ViewportOwner.bWindowsMouseAvailable)
	{
		// Set the windows cursor...
		ViewportOwner.SelectedCursor = Cursor.WindowsCursor;
	}
	else
	{
		x = MouseX + OriginX;
		y = MouseY + OriginY;

		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.bNoSmooth = True;
		C.Style=2;
		C.SetPos(x * GUIScale - Cursor.HotX, y * GUIScale - Cursor.HotY);
		C.DrawIcon(Cursor.tex, 1.0);
		C.Style=1;
	}
}

function bool KeyType( out EInputKey Key, optional string Unicode )
{
	if (ChildInteraction != None)
	{
		ChildInteraction.KeyType(Key, Unicode);
	}

	return true;	
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local bool result;

	if (RootInteraction == self)
	{
		if ( Action == IST_Axis && Key == IK_MouseX )
			MouseX = (ViewportOwner.WindowsMouseX / GUIScale) - OriginX;

		if ( Action == IST_Axis && Key == IK_MouseY )
			MouseY = ViewportOwner.WindowsMouseY / GUIScale - OriginY;
	}

	if (Console(ViewportOwner.Console) != None && Console(ViewportOwner.Console).bTyping)
		return true;
	
	if (ChildInteraction != None)
	{
		ChildInteraction.MouseX = MouseX;
		ChildInteraction.MouseY = MouseY;
		result = ChildInteraction.KeyEvent(Key, Action, Delta);
		if (result == true && RootInteraction != self)
			return true;
	}

	// ignore analog joysticks
	return (key == IK_JoyX || key == IK_JoyY || key == IK_JoyU || key == IK_JoyV);
}

function bool IsInteractionActive(class<Interaction> InteractionClass, PlayerController controller, optional Player AttachTo) 	// Adds an Interaction
{
	local array<Interaction> List;
	local Interaction Action;
	local int i;

	if (AttachTo != None)	// Handle location Interactions
	{
		List = AttachTo.LocalInteractions;
	}
	else	// Handle Global Interactions
	{
		List = controller.Player.InteractionMaster.GlobalInteractions;
	}

	for (i=0;i<List.Length;i++)
	{
		Action = List[i];
		if (InteractionClass == Action.Class)
		{
			return true;
		}
	}

	return false;
}

function Interaction PushInteraction(class<Interaction> NewInteractionClass, PlayerController controller, optional Player AttachTo, optional class<B9_MenuPDA_Menu> menu, optional B9_MenuInteraction FromOldMenu,optional class<B9_MenuInteraction> PrevOldMenuInteration,optional name ToPreviousOldMenu) 	// Adds an Interaction
{
	local Interaction NewInteraction;
	//local class<Interaction> NewInteractionClass;
	local B9_MenuInteraction B9MI;
	local B9_PDABase		 B9PDA;
	log("In Push Interaction");
	//NewInteractionClass = class<Interaction>(DynamicLoadObject(InteractionName, class'Class'));
	
	if (NewInteractionClass!=None)
	{
		Log("NewInteractionClass valid");
		NewInteraction = new(None) NewInteractionClass;
		if (NewInteraction != None)
		{
			Log("Menu Created");
			
			// Place the Interaction in the proper array
	
			if (AttachTo != None)	// Handle location Interactions
			{
				AttachTo.LocalInteractions.Insert(0, 1);
				AttachTo.LocalInteractions[0] = NewInteraction;
				NewInteraction.ViewportOwner = AttachTo;
			}
			else	// Handle Global Interactions
			{
				controller.Player.InteractionMaster.GlobalInteractions.Insert(0, 1);
				controller.Player.InteractionMaster.GlobalInteractions[0] = NewInteraction;
			}

			// Initialize the Interaction
			B9MI = B9_MenuInteraction(NewInteraction);
			
			B9MI.Initialize();
			B9MI.Master = controller.Player.InteractionMaster;
			B9MI.MenuInit(B9MI, controller, None);
			
			if( menu != None )
			{
				log("New Menu Made");
				B9PDA = B9_PDABase(NewInteraction);
				if( B9PDA != None )
				{
					log("Menu is PDA Based");
					B9PDA.fFromOldMenu = FromOldMenu;
					B9PDA.fOldChildInterationClass = PrevOldMenuInteration;
					B9PDA.fBackToLastState = ToPreviousOldMenu;

					B9PDA.AddMenu( menu );
				}
			}
			
			return NewInteraction;
		}
		else
  			Log("Could not create interaction ["$NewInteractionClass.Name$"]",'IMaster');
			
	}
	//else
	//	Log("Could not load interaction ["$InteractionName$"]",'IMaster');

	return none;	 	
	
} // PushInteraction

// pops first Interaction
function Interaction PopInteraction(PlayerController controller, optional Player AttachedTo)
{
	local Interaction I;

	// Grab the array to work with and find the Interaction to delete 
	log("Interaction Popped");
	if (AttachedTo != None)
	{
		if (AttachedTo.LocalInteractions.Length > 0)
		{
			I = AttachedTo.LocalInteractions[0];
			AttachedTo.LocalInteractions.Remove(0, 1);
			return I;
		}
	}
	else
	{
		if (controller.Player.InteractionMaster.GlobalInteractions.Length > 0)
		{
			I = controller.Player.InteractionMaster.GlobalInteractions[0];
			controller.Player.InteractionMaster.GlobalInteractions.Remove(0, 1);
			return I;
		}
	}
		

	Log("Could not pop interaction (List Empty)");

	return None;
} // PopInteraction			

function PopAllB9MenuInteractions(PlayerController controller, optional Player AttachedTo)
{
	local int i;

	// pop all interactions until a non-B9_MenuInteration is found

	if (AttachedTo != None)
	{
		for (i=0;i<AttachedTo.LocalInteractions.Length;i++)
		{
			if (AttachedTo.LocalInteractions[i].IsA('B9_MenuInteraction'))
			{
				AttachedTo.LocalInteractions.Remove(i, 1);
				--i;
			}
		}
	}

	for (i=0;i<controller.Player.InteractionMaster.GlobalInteractions.Length;i++)
	{
		if (controller.Player.InteractionMaster.GlobalInteractions[i].IsA('B9_MenuInteraction'))
		{
			controller.Player.InteractionMaster.GlobalInteractions.Remove(i, 1);
			--i;
		}
	}
}

function SetGenericString(int id, string s);
function SetGenericObject(int id, object o);
function SetGenericVector(int id, vector v);
function SetGenericRotator(int id, rotator r);

defaultproperties
{
	B9Fonts="B9_Fonts."
	bVisible=true
	bRequiresTick=true
}