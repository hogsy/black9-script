/////////////////////////////////////////////////////////////
// B9_PauseInteraction
//

class B9_PauseInteraction extends B9_MenuInteraction;

var int TABMOTION_Left;
var int TABMOTION_Right;

var bool ignoreDebugKeys;

var bool bOriginInited;
var string fPackageName;

var StorageEnvironment SE;
var HardDriveStorage HD;
var MemorySlotStorage MS[16];
var int MemorySlotTotal;
var array<SavedGameInfo> SGI;
var GameSaveStorage GSS;

var class<StorageEnvironment> StorageEnvironmentClass;
var class<HardDriveStorage> HardDriveStorageClass;
var class<MemorySlotStorage> MemorySlotStorageClass;
var class<HardDriveSavedGameInfo> HardDriveSavedGameInfoClass;
var class<MemorySlotSavedGameInfo> MemorySlotSavedGameInfoClass;

var class<B9_MenuInteraction> FileActionTabClass;
var class<B9_MenuInteraction> SkillsTabClass;
var class<B9_MenuInteraction> ItemsTabClass;
var class<B9_MenuInteraction> WeaponsTabClass;
var class<B9_MenuInteraction> FileSaveDeviceTabClass;
var class<B9_MenuInteraction> FileLoadDeviceTabClass;
var class<B9_MenuInteraction> FileLoadGameTabClass;
var class<B9_MenuInteraction> FileSaveGameTabClass;

var string ThePlatform;
var globalconfig int LoadE3Maps;

var bool	fCtrlKeyDown;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");
	ThePlatform = Platform();
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local int i;
	local B9_PlayerController pc;
	local B9_PlayerPawn pp;
	local B9_Calibration cal;

	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		ActivateMouse();

		pc = B9_PlayerController(controller);
		if (pc != None)
			B9_HUD(pc.myHUD).fHideHUD = true;

		MakeChildInteraction(FileActionTabClass);
		GotoState('FileActionTab');
	}
}

function StatefulEndMenu(B9_MenuInteraction interaction, int result)
{
	// Base class version should never be called.
}

function EndMenu(B9_MenuInteraction interaction, int result)
{
	if (interaction == ChildInteraction)
	{
		ChildInteraction = None;
		ignoreDebugKeys = false;

		StatefulEndMenu(interaction, result);
	}
}

function CollectStorageInfo()
{
	local int i;

	if (SE == None)
		SE = new(None) StorageEnvironmentClass;
	MemorySlotTotal = SE.MemorySlotCount();
	for (i=0;i<MemorySlotTotal;i++)
		MS[i] = SE.GetMemorySlotStorage(i);
	if (SE.HardDriveCount() > 0)
	{
		HD = SE.GetHardDriveStorage(0);
	}
	else HD = None;
}

state FileActionTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == TABMOTION_Right)
		{
			GotoState('SkillsTab');
			MakeChildInteraction(SkillsTabClass);
		}
		else if (result == TABMOTION_Left)
		{
			GotoState('ItemsTab');
			MakeChildInteraction(ItemsTabClass);
		}
		else if (result == -1)
		{
			PopInteraction(RootController, RootController.Player);
		}
		else if (result == 0)
		{
			if( LoadE3Maps == 0 )
			{
 				GotoState('FileSaveDeviceTab');
 				MakeChildInteraction(FileSaveDeviceTabClass);
			}else
			{
				// Map One
				ViewportOwner.bShowWindowsMouse = false;
				PopInteraction(RootController, RootController.Player);

				SwitchToMatinee('');
				GotoMapWithPawn("M06A10");
			}
		}
		else if (result == 1)
		{
			if( LoadE3Maps == 0 )
			{
 				GotoState('FileLoadDeviceTab');
  				MakeChildInteraction(FileLoadDeviceTabClass);

			}else
			{
				// Map Two
				ViewportOwner.bShowWindowsMouse = false;
				PopInteraction(RootController, RootController.Player);

				SwitchToMatinee('');
				GotoMapWithPawn("M09A01");
			}
		}
		else if( result == 2 ) 
		{
			if( LoadE3Maps != 0 )
			{
				// Map 3
				ViewportOwner.bShowWindowsMouse = false;
				PopInteraction(RootController, RootController.Player);

				SwitchToMatinee('');
				GotoMapWithPawn("M06A05");
			}
		}
		else
		{
			MakeChildInteraction(FileActionTabClass);
		}
	}
}

state FileLoadDeviceTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		local int i, n;

		if (result == -1)
		{
			GotoState('FileActionTab');
			MakeChildInteraction(FileActionTabClass);
		}
		else
		{
			if (result == 0 && HD != None)
			{
				// hard drive
				GSS = HD;
			}
			else
			{
				// memory slot
				n = result;
				if (HD != None) --n;
				GSS = MS[n];
			}

			SGI.Length = GSS.GetGameSaveCount();
			for (i=0;i<SGI.Length;i++)
				SGI[i] = GSS.GetGameSaveInfo(i);

			GotoState('FileLoadGameTab');
			MakeChildInteraction(FileLoadGameTabClass);
		}
	}
}

state FileLoadGameTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1)
		{
			GotoState('FileLoadDeviceTab');
			MakeChildInteraction(FileLoadDeviceTabClass);
		}
		else
		{
			PopInteraction(RootController, RootController.Player);
			SGI[result].LoadGame(RootController);
			
			MakeChildInteraction(FileLoadGameTabClass);
		}
	}
}

state FileSaveDeviceTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		local int i, n;

		if (result == -1)
		{
			GotoState('FileActionTab');
			MakeChildInteraction(FileActionTabClass);
		}
		else
		{
			if (result == 0 && HD != None)
			{
				// hard drive
				GSS = HD;
			}
			else
			{
				// memory slot
				n = result;
				if (HD != None) --n;
				GSS = MS[n];
			}

			SGI.Length = GSS.GetGameSaveCount();
			for (i=0;i<SGI.Length;i++)
				SGI[i] = GSS.GetGameSaveInfo(i);

			GotoState('FileSaveGameTab');
			MakeChildInteraction(FileSaveGameTabClass);
		}
	}
}


state FileSaveGameTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		local SavedGameInfo info;

		if (result == -1)
		{
			GotoState('FileSaveDeviceTab');
			MakeChildInteraction(FileSaveDeviceTabClass);
		}
		else
		{
			PopInteraction(RootController, RootController.Player);
			if (result < SGI.Length)
				info = SGI[result];
			GSS.SaveGame(RootController, info);
		}
	}
}

state SkillsTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == TABMOTION_Right)
		{
			GotoState('WeaponsTab');
			MakeChildInteraction(WeaponsTabClass);
		}
		else if (result == TABMOTION_Left)
		{
			GotoState('FileActionTab');
			MakeChildInteraction(FileActionTabClass);
		}
		else if (result == -1)
		{
			PopInteraction(RootController, RootController.Player);
		}
		else
		{
			MakeChildInteraction(SkillsTabClass);
		}
	}
}

state WeaponsTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == TABMOTION_Right)
		{
			GotoState('ItemsTab');
			MakeChildInteraction(ItemsTabClass);
		}
		else if (result == TABMOTION_Left)
		{
			GotoState('SkillsTab');
			MakeChildInteraction(SkillsTabClass);
		}
		else if (result == -1)
		{
			PopInteraction(RootController, RootController.Player);
		}
		else
		{
			MakeChildInteraction(WeaponsTabClass);
		}
	}
}

state ItemsTab
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == TABMOTION_Right)
		{
			GotoState('FileActionTab');
			MakeChildInteraction(FileActionTabClass);
		}
		else if (result == TABMOTION_Left)
		{
			GotoState('WeaponsTab');
			MakeChildInteraction(WeaponsTabClass);
		}
		else if (result == -1)
		{
			PopInteraction(RootController, RootController.Player);
		}
		else
		{
			MakeChildInteraction(ItemsTabClass);
		}
	}
}
state OptionSubMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if( Result == 0)
		{
			
		}
	}
}
function PostRender( canvas Canvas )
{
	local int locX, locY;
	local color black, blue, white, yellow;
	local font oldFont;
	local float oldOrgX, oldOrgY;
	local string s;

	local Pawn pawn, oldPawn;
	local vector loc;

	if (!bOriginInited)
	{
		RootInteraction.SetOrigin((Canvas.ClipX - 640) / 2, (Canvas.ClipY - 480) / 2);
		bOriginInited = true;
	}

	oldOrgX = Canvas.OrgX;
	oldOrgX = Canvas.OrgY;

	Canvas.SetOrigin(RootInteraction.OriginX, RootInteraction.OriginY); 

	Super.PostRender( Canvas );

	Canvas.SetOrigin(oldOrgX, oldOrgY); 

	white.R = 255;
	white.G = 255;
	white.B = 255;

	blue.R = 0;
	blue.G = 200;
	blue.B = 245;

	yellow.R = 245;
	yellow.G = 245;
	yellow.B = 200;

	black.R = 0;
	black.G = 0;
	black.B = 0;

	locX = 20;
	locY = 20;

	// debugging menu

/*
	s = ">>> '" $ MS[MemorySlotTotal-1].GetLabel() $ "' '" $ HD.GetLabel() $ "' " $ HD.GetGameSaveCount() $ " '" $ SGI.Label $ "' '" $ SGI.SaveTag $ "'";
	DrawTextWithShadow( Canvas, s, locX, 390, yellow, black );
*/

/*
	DrawTextWithShadow( Canvas, SGI.CharacterName, locX, 330, yellow, black );
	DrawTextWithShadow( Canvas, SGI.SaveDate, locX + 100, 330, yellow, black );
	DrawTextWithShadow( Canvas,
		"STR " $ string(SGI.CharacterStrength) $
		"  AGL " $ string(SGI.CharacterAgility) $
		"  DEX " $ string(SGI.CharacterDexterity) $
		"  CON " $ string(SGI.CharacterConstitution),
		locX, 350, yellow, black );
	DrawTextWithShadow( Canvas,
		"HEALTH: " $ string(SGI.CharacterCurHealth) $ "/" $ string(SGI.CharacterFullHealth) $
		"    CHI: " $ string(SGI.CharacterCurFocus) $ "/" $ string(SGI.CharacterFullFocus) $
		"  CASH: $" $ string(SGI.CharacterCash),
		locX, 370, yellow, black );
	DrawTextWithShadow( Canvas, SGI.MissionDescription, locX, 390, yellow, black );
	//var const Texture ScreenShot;
*/

	MouseRender( Canvas );
}

function Interaction PopInteraction(PlayerController controller, optional Player AttachedTo)
{
	local B9_HUD hud;
	local Interaction I;

	I = Super.PopInteraction(controller, AttachedTo);
	hud = B9_HUD(B9_PlayerController(controller).myHUD);
	hud.fPauseMenu = None;
	hud.fHideHUD = false;
	controller.SetPause(false);
	return I;
}


function GotoMapWithPawn(string mapname)
{
	RootController.ClientTravel( mapname, TRAVEL_Absolute, true );
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local bool result;

	if (Super.KeyEvent( Key, Action, Delta ))
		return true;

	if (ignoreDebugKeys)
		return true;
		
	if( Action == IST_Press && Key == IK_Ctrl )
	{
		fCtrlKeyDown = true;
		return true;
	}
	else if( Action == IST_Release && Key == IK_Ctrl )
	{
		fCtrlKeyDown = false;
		return true;
	}			
		
	if( fCtrlKeyDown )
	{		
		if( Action == IST_Press && Key == IK_Q)
		{
			RootController.Player.Actor.ConsoleCommand("exit");
		}
		else if ( Action == IST_Release && Key == IK_R )
		{
			ViewportOwner.bShowWindowsMouse = false;
			PopInteraction(RootController, RootController.Player);
		}
		else if (Action == IST_Release && Key == IK_G )
		{
			ViewportOwner.bShowWindowsMouse = false;
			PopInteraction(RootController, RootController.Player);

			SwitchToMatinee('');
			GotoMapWithPawn("M06A01");
		}
		else if (Action == IST_Release && Key == IK_H )
		{
			ViewportOwner.bShowWindowsMouse = false;
			PopInteraction(RootController, RootController.Player);

			SwitchToMatinee('');
			GotoMapWithPawn("e1hq");
		}
	}

	
/*
	else if (Action == IST_Press && (Key == IK_Escape || Key == IK_Pause))
	{
		PopInteraction(RootController, RootController.Player);
	}
*/

	return true;
}

defaultproperties
{
	TABMOTION_Left=1000
	TABMOTION_Right=1001
	fPackageName="B9Menus"
	StorageEnvironmentClass=Class'StorageEnvironment'
	HardDriveStorageClass=Class'HardDriveStorage'
	MemorySlotStorageClass=Class'MemorySlotStorage'
	HardDriveSavedGameInfoClass=Class'HardDriveSavedGameInfo'
	MemorySlotSavedGameInfoClass=Class'MemorySlotSavedGameInfo'
	FileActionTabClass=Class'B9_PM_FileActionTab'
	SkillsTabClass=Class'B9_PM_SkillsTab'
	ItemsTabClass=Class'B9_PM_ItemsTab'
	WeaponsTabClass=Class'B9_PM_WeaponsTab'
	FileSaveDeviceTabClass=Class'B9_PM_FileSaveDeviceTab'
	FileLoadDeviceTabClass=Class'B9_PM_FileLoadDeviceTab'
	FileLoadGameTabClass=Class'B9_PM_FileLoadGameTab'
	FileSaveGameTabClass=Class'B9_PM_FileSaveGameTab'
	LoadE3Maps=1
}