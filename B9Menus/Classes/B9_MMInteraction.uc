/////////////////////////////////////////////////////////////
// B9_MMInteraction
//

class B9_MMInteraction extends B9_MenuInteraction;

#exec OBJ LOAD FILE=..\textures\B9Menu_tex_std.utx PACKAGE=B9Menu_tex_std

var string fCharName;
var class<Pawn> fCharClass;
var int fStrength;
var int fAgility;
var int fDexterity;
var int fConstitution;

var class<Inventory> DefaultItemClasses[10];
var class<Pawn> PlayerCharacterClasses[4];

var string fPackageName;

var bool ignoreDebugKeys;

var Actor startingViewTarget;
var bool bOriginInited;

var Pawn thePlayerPawn;
var float fSpecialEyeHeight;

var B9_CharacterManager fCharacterManager;
var class<B9_CharacterManager> fCharacterManagerClass;

var bool fLAN;

var class<B9_MenuInteraction> TopLevelMenuClass;
var class<B9_MenuInteraction> SinglePlayerMenuClass;
var class<B9_MenuInteraction> NewCareerNameMenuClass;
var class<B9_MenuInteraction> NewCareerPickMenuClass;
var class<B9_MenuInteraction> NewCareerReadyMenuClass;
var class<B9_MenuInteraction> NewCareerStatsMenuClass;
var class<B9_MenuInteraction> MultiPlayer_CharactersMenuClass;
var class<B9_MenuInteraction> MultiPlayer_DeleteCharactersMenuClass;
var class<B9_MenuInteraction> MultiPlayer_GamesMenuClass;
var class<B9_MenuInteraction> MultiPlayer_AccountListMenuClass;
var class<B9_MenuInteraction> MultiPlayer_Wait4LoginMenuClass;
var class<B9_MenuInteraction> MultiPlayer_WaitWhileSearchingMenuClass;
var class<B9_MenuInteraction> MultiPlayer_MatchOrCreateMenuClass;
 
var() localized string  GoToLunaII;
var() localized string 	GoToHQ;
var() localized string 	RemoveInt;
var() localized string 	Quit;

var B9MP_ClientManager fClientManager;

var string ThePlatform;

var bool	fCtrlKeyDown;

var globalconfig bool	bUseE3Menus;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");
	ThePlatform = Platform();
}

// Temporary code. Already in B9_MenuPDA_Menu
function string MapSpecialChars(string URN)
{
	local int nIndex;
	local string Result;

	while(true)
	{
		nIndex = InStr(URN, " ");
		if(nIndex < 0)
		{
			break;
		}

		Result = Result $ Left(URN, nIndex) $ "%20";
		URN = Right(URN, Len(URN) - nIndex - 1);
	}

	if(Result == "")
	{
		Result = URN;
	}

	return Result;
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local MenuUtility utils;
	local int i;

	Super.MenuInit(interaction, controller, parent);

	InitHandlers( controller );

	if (RootInteraction == self)
	{
		ActivateMouse();

		utils = new(None) class'MenuUtility';
		utils.ResetInput(RootController);
		utils.DirectAxisEnable(RootController, false);

		if( bUseE3Menus == false )
		{
			MakeChildInteraction(TopLevelMenuClass);

			fMatineeTag = 'MenuStart';
		}
		
		// !!!! for debugging purposes 
		fStrength = 15;
		fAgility = 16;
		fDexterity = 15;
		fConstitution = 15;
		fCharName = "Samara";
		fCharClass = PlayerCharacterClasses[0];

		if( bUseE3Menus == false )
		{
log("Using Old Menus");
			GotoState('TopLevelMenu');
		}
		else
		{
log("Using New E3 Menus");
			if (!IsInteractionActive(class'B9_PDABase', RootController, RootController.Player))
			{
				//PushInteraction(class'B9_PDABase', self, self.Player,Testmenu);
				PushInteraction(class'B9_PDABase', RootController, RootController.Player,class'B9_PDA_TopLevelMenu');
			}
		}

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
		ChildInteraction.DeInitialize();

		ChildInteraction = None;
		ignoreDebugKeys = false;

		StatefulEndMenu(interaction, result);
	}
}

function InitHandlers( PlayerController controller )
{
	local class<B9MP_ClientManager> fClientManagerClass;
	local String onlinePkgNameSuffix;
	
	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}

	if ( fCharacterManager == None )
	{
		ForEach controller.AllActors( class'B9_CharacterManager', fCharacterManager )
		{
			break;
		}

		if ( fCharacterManager == None )
		{
			fCharacterManager = controller.Spawn( fCharacterManagerClass );
		}
	}
	
	if ( fClientManager == None )
	{
		ForEach controller.AllActors( class'B9MP_ClientManager', fClientManager )
		{
			break;
		}
		
		if ( fClientManager == None )
		{
			fClientManagerClass = class<B9MP_ClientManager>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ClientManager_" $ onlinePkgNameSuffix, class'Class'));
			fClientManager = controller.Spawn( fClientManagerClass );			
		}
	}	
}


state TopLevelMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		switch ( result )
		{
		case 0:
			// Single Player
			GotoState('SinglePlayerMenu');
			MakeChildInteraction(SinglePlayerMenuClass);
			break;

		case 1:
			// Multi Player
			GotoState('MultiPlayer_CharactersMenu');
			MakeChildInteraction(MultiPlayer_CharactersMenuClass);
			break;

		case 4:
			// PC - Quit
			RootController.Player.Actor.ConsoleCommand("exit");
			break;

		default:
			MakeChildInteraction(TopLevelMenuClass);
			break;
		}
	}
}

state SinglePlayerMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to main menu
		{
			GotoState('TopLevelMenu');
			MakeChildInteraction(TopLevelMenuClass);
		}
		else if (result == 0)
		{
			GotoState('NewCareerPickMenuSP');
			MakeChildInteraction(NewCareerPickMenuClass);
		}
		else
		{
			MakeChildInteraction(SinglePlayerMenuClass);
		}
	}
}

state MultiPlayer_CharactersMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		switch ( result )
		{
		case -1:
			// Go back a menu
			GotoState('TopLevelMenu');
			MakeChildInteraction(TopLevelMenuClass);
			break;

		case 0:
			// New character
			GotoState('NewCareerPickMenuMP');
			MakeChildInteraction(NewCareerPickMenuClass);
			break;

		case 1:
			// Delete character
			if ( fCharacterManager.fCharacterCount > 0 )
			{
				GotoState('Multiplayer_DeleteCharactersMenu');
				MakeChildInteraction(MultiPlayer_DeleteCharactersMenuClass);
			}
			else
			{
				GotoState('MultiPlayer_CharactersMenu');
				MakeChildInteraction(MultiPlayer_CharactersMenuClass);
			}
			break;

		default:
			// Play given character
			GotoState('Multiplayer_AccountListMenu');
			MakeChildInteraction(MultiPlayer_AccountListMenuClass);
			break;
		}
	}
}

state Multiplayer_AccountListMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		switch ( result )
		{
		case -1:
			// Go back a menu
			GotoState('MultiPlayer_CharactersMenu');
			MakeChildInteraction(MultiPlayer_CharactersMenuClass);
			break;

		case 0:
			// New account
			//GotoState('Multiplayer_AddAccountMenu');
			//MakeChildInteraction(fPackageName $ ".B9_MM_AddAccountMenu");
			break;

		case 1:
			// Delete account
			if ( fClientManager.fClients.GetCount() > 0 )
			{
				//GotoState('Multiplayer_DeleteAccountMenu');
				//MakeChildInteraction(fPackageName $ ".B9_MM_MultiPlayer_DeleteAccountMenu");
			}
			break;

		default:
			// Play given character
			GotoState('Multiplayer_Wait4LoginMenu');
			MakeChildInteraction(MultiPlayer_Wait4LoginMenuClass);
			break;
		}
	}	
}

state Multiplayer_Wait4LoginMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		switch ( result )
		{
		case 0:
			GotoState('Multiplayer_MatchOrCreateMenu');
			MakeChildInteraction(MultiPlayer_MatchOrCreateMenuClass);
			break;

		default:
			// Go back a menu
			GotoState('MultiPlayer_AccountListMenu');
			MakeChildInteraction(MultiPlayer_AccountListMenuClass);
			break;
		}
	}
}

state Multiplayer_MatchOrCreateMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		local name thisState;
		
	//	local class<B9_MenuPDA_Menu> Testmenu;
		local B9_PlayerController PlayerController;
	//	Testmenu = class<B9_MenuPDA_Menu>(DynamicLoadObject("B9Menus.Test_PDA_Menu", class'Class'));
		thisState = 'Multiplayer_AccountListMenu';
		switch ( result )
		{
		case -1:
			// Go back a menu
			GotoState('MultiPlayer_AccountListMenu');
			MakeChildInteraction(MultiPlayer_AccountListMenuClass);
			break;

		case 0:
			// Quick match
			GotoState('Multiplayer_GamesMenu');
			MakeChildInteraction(MultiPlayer_GamesMenuClass);
			break;

		case 1:
			// OptiMatch
			fLAN = false;
			GotoState('Multiplayer_WaitWhileSearchingMenu');
			MakeChildInteraction(Multiplayer_WaitWhileSearchingMenuClass);
			break;

		case 2:
			if ( ! IsPlatformXBox() )
			{
				// OptiMatch LAN
				fLAN = true;

//B9_PDA_TopLevelMenu
				log("Pulling up the PDA");
				if (!IsInteractionActive(class'B9_PDABase', RootController, RootController.Player))
				{
					//PushInteraction(class'B9_PDABase', self, self.Player,Testmenu);
					if ( bUseE3Menus )
						PushInteraction(class'B9_PDABase', RootController, RootController.Player,class'B9_PDA_TopLevelMenu',self,MultiPlayer_MatchOrCreateMenuClass,thisState);
					else
						PushInteraction(class'B9_PDABase', RootController, RootController.Player,class'B9_PDA_HostOrJoinLanMenu',self,MultiPlayer_MatchOrCreateMenuClass,thisState);
				}


//				GotoState('Multiplayer_WaitWhileSearchingMenu');
//				MakeChildInteraction(Multiplayer_WaitWhileSearchingMenuClass);
			}
			break;

		default:
			// Create game and play given character
			break;
		}
	}
}

state Multiplayer_WaitWhileSearchingMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		switch ( result )
		{
		case 0:
			GotoState('Multiplayer_GamesMenu');
			MakeChildInteraction(MultiPlayer_GamesMenuClass);
			break;

		default:
			// Go back a menu
			GotoState('Multiplayer_MatchOrCreateMenu');
			MakeChildInteraction(MultiPlayer_MatchOrCreateMenuClass);
			break;
		}
	}
}

state Multiplayer_GamesMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1)
		{
			// Go back a menu
			GotoState('Multiplayer_MatchOrCreateMenu');
			MakeChildInteraction(MultiPlayer_MatchOrCreateMenuClass);
		}
	}
}


state Multiplayer_DeleteCharactersMenu
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		// Go back a menu
		GotoState('MultiPlayer_CharactersMenu');
		MakeChildInteraction(MultiPlayer_CharactersMenuClass);
	}
}


state NewCareerPickMenuSP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to single-player menu
		{
			GotoState('SinglePlayerMenu');
			MakeChildInteraction(SinglePlayerMenuClass);
		}
		else if (result == 0)
		{
			B9_MM_NewCareerPickMenu(interaction).GetPick(fStrength,fAgility,fDexterity,fConstitution,fCharName,fCharClass);

			GotoState('NewCareerNameMenuSP');
			MakeChildInteraction(NewCareerNameMenuClass);
			B9_MM_NewCareerNameMenu(ChildInteraction).SetName(fCharName);
			ignoreDebugKeys = true;
		}
	}
}


state NewCareerPickMenuMP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1)
		{
			// Multi Player
			GotoState('MultiPlayer_CharactersMenu');
			MakeChildInteraction(MultiPlayer_CharactersMenuClass);
		}
		else if (result == 0)
		{
			B9_MM_NewCareerPickMenu(interaction).GetPick(fStrength,fAgility,fDexterity,fConstitution,fCharName,fCharClass);

			GotoState('NewCareerNameMenuMP');
			MakeChildInteraction(NewCareerNameMenuClass);
			B9_MM_NewCareerNameMenu(ChildInteraction).SetName(fCharName);
			ignoreDebugKeys = true;
		}
	}
}


state NewCareerNameMenuSP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to single-player menu
		{
			GotoState('NewCareerPickMenuSP');
			MakeChildInteraction(NewCareerPickMenuClass);
		}
		else if (result == 0)
		{
			B9_MM_NewCareerNameMenu(interaction).GetName(fCharName);

			GotoState('NewCareerStatsMenuSP');
			MakeChildInteraction(NewCareerStatsMenuClass);

			B9_MM_NewCareerStatsMenu(ChildInteraction).SetStats(fStrength,fAgility,fDexterity,fConstitution);
		}
	}
}

state NewCareerNameMenuMP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to single-player menu
		{
			GotoState('NewCareerPickMenuSP');
			MakeChildInteraction(NewCareerPickMenuClass);
		}
		else if (result == 0)
		{
			B9_MM_NewCareerNameMenu(interaction).GetName(fCharName);

			GotoState('NewCareerStatsMenuMP');
			MakeChildInteraction(NewCareerStatsMenuClass);

			B9_MM_NewCareerStatsMenu(ChildInteraction).SetStats(fStrength,fAgility,fDexterity,fConstitution);
		}
	}
}

state NewCareerStatsMenuSP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to new career name menu
		{
			GotoState('NewCareerNameMenuSP');
			MakeChildInteraction(NewCareerNameMenuClass);
			B9_MM_NewCareerNameMenu(ChildInteraction).SetName(fCharName);
			ignoreDebugKeys = true;
		}
		else
		{
			B9_MM_NewCareerStatsMenu(interaction).GetStats(fStrength,fAgility,fDexterity,fConstitution);

			GotoState('NewCareerReadyMenuSP');
			MakeChildInteraction(NewCareerReadyMenuClass);
		}
	}
}

state NewCareerStatsMenuMP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to new career name menu
		{
			GotoState('NewCareerNameMenuMP');
			MakeChildInteraction(NewCareerNameMenuClass);
			B9_MM_NewCareerNameMenu(ChildInteraction).SetName(fCharName);
			ignoreDebugKeys = true;
		}
		else
		{
			B9_MM_NewCareerStatsMenu(interaction).GetStats(fStrength,fAgility,fDexterity,fConstitution);

			GotoState('NewCareerReadyMenuMP');
			MakeChildInteraction(NewCareerReadyMenuClass);
		}
	}
}

state NewCareerReadyMenuSP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to new career name menu
		{
			GotoState('NewCareerStatsMenuSP');
			MakeChildInteraction(NewCareerStatsMenuClass);
			B9_MM_NewCareerStatsMenu(ChildInteraction).SetStats(fStrength,fAgility,fDexterity,fConstitution);
		}
		else
		{
			PopInteraction(RootController, RootController.Player);

			GotoMapWithPawn("e1hq", fCharClass);
		}
	}
}

state NewCareerReadyMenuMP
{
	function StatefulEndMenu(B9_MenuInteraction interaction, int result)
	{
		if (result == -1) // go back to new career name menu
		{
			GotoState('NewCareerStatsMenuMP');
			MakeChildInteraction(NewCareerStatsMenuClass);
			B9_MM_NewCareerStatsMenu(ChildInteraction).SetStats(fStrength,fAgility,fDexterity,fConstitution);
		}
		else
		{
			// Well, add it then
			InsurePlayerIsSet( fCharClass );
			fCharacterManager.AddCharacter( fCharName, RootController.Player.Actor.Pawn, fCharClass );

			// Change our view back to normal menus
//			RootController.SetViewTarget( startingViewTarget );
			RootController.SetViewTarget( None );

			// Multi Player
			GotoState('MultiPlayer_CharactersMenu');
			MakeChildInteraction(MultiPlayer_CharactersMenuClass);
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

		// This code tries to find the player pawn, hide it and set the eye height variables
		// so the matinee will smoothly run and transition into normal play mode. The
		// variable fSpecialEyeHeight was added to B9_PlayerPawn to facilitate this -- also
		// required overriding ClientRestart().
		ForEach RootController.AllActors(class'Pawn', pawn)
		{
			s = "" $ pawn.Tag;
			if (pawn.IsA('B9_PlayerPawn') && InStr(s, "B9_BodyType") != 0)
			{
				pawn.bHidden = true;
				pawn.BaseEyeHeight = fSpecialEyeHeight;
				B9_PlayerPawn(pawn).fSpecialEyeHeight = fSpecialEyeHeight;
				thePlayerPawn = pawn;
				break;
			}
		}
	}
	else
	{
		if (thePlayerPawn != None && thePlayerPawn.BaseEyeHeight != fSpecialEyeHeight)
		{
			Log("Reset eye height");
			thePlayerPawn.BaseEyeHeight = fSpecialEyeHeight;
		}
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
	// Removed for E3 demo
	/*
	DrawTextWithShadow( Canvas, GoToLunaII, locX, locY, blue, black );
	DrawTextWithShadow( Canvas, GoToHQ, locX, locY + 18, blue, black );
	DrawTextWithShadow( Canvas, RemoveInt, locX, locY + 36, blue, black );
	DrawTextWithShadow( Canvas, Quit, locX, locY + 54, blue, black );

	DrawTextWithShadow( Canvas, ThePlatform, locX, 420, blue, black );
*/
	MouseRender( Canvas );
}


function InsurePlayerIsSet( class<Pawn> pawnType )
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local Inventory Inv;
	local class<Inventory> DefaultSkill;
	local class<Inventory> DefaultWeapon;
	local class<Inventory> DefaultItem;
	local B9WeaponBase		b9Weapon;
	local int i;

	Log( "MMenu: Attempting to spawn " $ pawntype );

	ForEach RootController.AllActors( class'Actor', A )
	{
		if ( bUseE3Menus )
		{
			if ( A.Name == 'LookTarget0' )
			{
				loc = A.location;
				break;
			}
		}
		else
			if ( A.Name == 'LookTarget8' )
			{
				loc = A.location;
				break;
			}
	}

	pawn = RootController.spawn( pawnType, , , loc );
	if ( pawn != None )
	{
		Log( "MMenu: spawned" );

		if ( RootController.pawn != None )
		{
			Log( "MMenu: unpossess" );

			oldPawn = RootController.pawn;
			RootController.UnPossess();
			oldPawn.Destroy();
		}

		Log( "MMenu: possess" );

		RootController.Possess( pawn );
	}
	else
		Log( "MMenu: Failed to create pawn" );

/*
	Log( "MMenu: Pawn [" $ Pawn $ "] RootController [" $ RootController $ "] RC.Player.Actor [" $ RootController.Player.Actor $ "] RC.Pawn [" $ RootController.Pawn $ "] RC.P.A.Pawn [" $ RootController.Player.Actor.Pawn $ "]" );

	if ( pawn == RootController.Player.Actor.Pawn )
		Log( "MMenu: pawns match" );
	else
		Log( "MMenu: pawns do NOT match" );

	if ( RootController == RootController.Player.Actor )
		Log( "MMenu: controllers match" );
	else
		Log( "MMenu: controllers do NOT match" );

	if ( RootController.Pawn == RootController.Player.Actor.Pawn )
		Log( "MMenu: RC pawns match" );
	else
		Log( "MMenu: RC pawns do NOT match" );

ScriptLog: MMenu: Attempting to spawn B9Characters.B9_player_norm_male
ScriptLog: MMenu: spawned
ScriptLog: MMenu: unpossess
ScriptLog: MMenu: possess
ScriptLog: Calling Play Waiting from PlayMoving
ScriptLog: MMenu: 
Pawn [B9menu_main.B9_player_norm_male1]
RootController [B9menu_main.B9_MainMenuController0] 
RC.Player.Actor [B9menu_main.B9_MainMenuController0] 
RC.Pawn [B9menu_main.B9_player_norm_male1] 
RC.P.A.Pawn [B9menu_main.B9_player_norm_male1]
ScriptLog: MMenu: pawns match
ScriptLog: MMenu: controllers match
ScriptLog: MMenu: RC pawns match
*/

/*
Original
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterOccupation Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterCompany Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterName Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterCash Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterSkillPoints Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterConcludedMission Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fSelectedWeaponID Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fSelectedItemID Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fSelectedSkillID Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterBaseStrength Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterBaseAgility Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterBaseDexterity Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterBaseConstitution Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fCharacterMaxHealth Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: kBodyType Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: fSelectedSkill Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: Weapon Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: SelectedItem Index: 0)
Log: ExportTravel: Bad Defaults(0) Ptr (Class: Health Index: 0)
*/


	// another test
	pawn = RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).fCharacterBaseStrength		= fStrength;
	B9_PlayerPawn(pawn).fCharacterBaseAgility		= fAgility;
	B9_PlayerPawn(pawn).fCharacterBaseDexterity		= fDexterity;
	B9_PlayerPawn(pawn).fCharacterBaseConstitution	= fConstitution;
	B9_PlayerPawn(pawn).fCharacterName				= fCharName;

	// Gain the Default items/skills if we don't have it already
	for (i=0;i<8;i++)
	{
		if (DefaultItemClasses[i] != None)
		{
			if ( B9_PlayerPawn(pawn).FindInventoryType( DefaultItemClasses[i] ) == None )
			{
 				Inv = RootController.Spawn( DefaultItemClasses[i] );
 				Inv.GiveTo( B9_PlayerPawn(pawn) );
			}
		}
	}

	B9_PlayerPawn(pawn).ApplyModifications();

	B9_PlayerPawn(pawn).SetMultiplayer();
}


function GotoMapWithPawn(string mapname, class<Pawn> pawntype)
{
	local MenuUtility utils;

	InsurePlayerIsSet( pawnType );
	RootController.ClientTravel( mapname $ "?Class=" $ pawntype, TRAVEL_Absolute, true );

	utils = new(None) class'MenuUtility';
	utils.DirectAxisEnable(RootController, true);
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local MenuUtility utils;
	local bool result;

	if (Super.KeyEvent( Key, Action, Delta ))
		return true;

	if (ignoreDebugKeys)
		return true;

	if ( bUseE3Menus )
	{
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

				utils = new(None) class'MenuUtility';
				utils.DirectAxisEnable(RootController, true);
			}
			else if (Action == IST_Release && Key == IK_G )
			{
				ViewportOwner.bShowWindowsMouse = false;
				PopInteraction(RootController, RootController.Player);

				SwitchToMatinee('');
				GotoMapWithPawn("M06A01", fCharClass);
			}
			else if (Action == IST_Release && Key == IK_H )
			{
				ViewportOwner.bShowWindowsMouse = false;
				PopInteraction(RootController, RootController.Player);

				SwitchToMatinee('');
				GotoMapWithPawn("e1hq", fCharClass);
			}
		}
	}
	else
	{
		if( Action == IST_Press && Key == IK_Q)
		{
			RootController.Player.Actor.ConsoleCommand("exit");
		}
		else if ( Action == IST_Release && Key == IK_R )
		{
			ViewportOwner.bShowWindowsMouse = false;
			PopInteraction(RootController, RootController.Player);

			utils = new(None) class'MenuUtility';
			utils.DirectAxisEnable(RootController, true);
		}
		else if (Action == IST_Release && Key == IK_G )
		{
			ViewportOwner.bShowWindowsMouse = false;
			PopInteraction(RootController, RootController.Player);

			SwitchToMatinee('');
			GotoMapWithPawn("M06A01", fCharClass);
		}
		else if (Action == IST_Release && Key == IK_H )
		{
			ViewportOwner.bShowWindowsMouse = false;
			PopInteraction(RootController, RootController.Player);

			SwitchToMatinee('');
			GotoMapWithPawn("e1hq", fCharClass);
		}
	}

	return true;
}

defaultproperties
{
	DefaultItemClasses[0]=Class'B9NanoSkills.skill_Hacking'
	DefaultItemClasses[1]=Class'B9Weapons.HandToHand'
	DefaultItemClasses[2]=Class'B9Gear.PDA'
	DefaultItemClasses[3]=Class'B9NanoSkills.skill_Jumping'
	DefaultItemClasses[4]=Class'B9NanoSkills.skill_meleeCombat'
	DefaultItemClasses[5]=Class'B9NanoSkills.skill_FireArmsTargeting'
	DefaultItemClasses[6]=Class'B9NanoSkills.skill_HeavyWeaponsTargeting'
	DefaultItemClasses[7]=Class'B9NanoSkills.skill_urbanTracking'
	fPackageName="B9Menus"
	fSpecialEyeHeight=60.75
	fCharacterManagerClass=Class'B9Characters.B9_CharacterManager'
	TopLevelMenuClass=Class'B9_MM_TopLevelMenu'
	SinglePlayerMenuClass=Class'B9_MM_SinglePlayerMenu'
	NewCareerNameMenuClass=Class'B9_MM_NewCareerNameMenu'
	NewCareerPickMenuClass=Class'B9_MM_NewCareerPickMenu'
	NewCareerReadyMenuClass=Class'B9_MM_NewCareerReadyMenu'
	NewCareerStatsMenuClass=Class'B9_MM_NewCareerStatsMenu'
	MultiPlayer_CharactersMenuClass=Class'B9_MM_MultiPlayer_CharactersMenu'
	MultiPlayer_DeleteCharactersMenuClass=Class'B9_MM_MultiPlayer_DeleteCharactersMenu'
	MultiPlayer_GamesMenuClass=Class'B9_MM_MultiPlayer_GamesMenu'
	MultiPlayer_AccountListMenuClass=Class'B9_MM_MultiPlayer_AccountListMenu'
	MultiPlayer_Wait4LoginMenuClass=Class'B9_MM_MultiPlayer_Wait4LoginMenu'
	MultiPlayer_WaitWhileSearchingMenuClass=Class'B9_MM_MultiPlayer_WaitWhileSearchingMenu'
	MultiPlayer_MatchOrCreateMenuClass=Class'B9_MM_Multiplayer_MatchOrCreateMenu'
	GoToLunaII="G: Goto Luna II level"
	GoToHQ="H: Goto Genesis HQ"
	RemoveInt="R: Remove Interaction"
	Quit="Q: Quit"
	bUseE3Menus=true
}