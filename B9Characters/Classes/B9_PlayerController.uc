//=============================================================================
// B9_PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// 
//=============================================================================

class B9_PlayerController extends B9_PlayerControllerBase;

// New 3rd person camera
var transient B9_CameraController2 fCamera;

// targeting
var public bool	bLockTargetDesired;
var public int	fCycleTarget;



// New movement inputs!
var float fAwayFromCamera, fWithCamera;
var input float fSniperZoom;

var protected vector fLastVelocity;

var	protected B9_Pawn.ESpecialAnimation fSpecialAnimation;
var private name fPrevState;

// Menus stuff
var private bool fResetHUD;

// Animation stuff
var protected int CurrentGesture;

// Jump timing
var float fDelayedJumpTime;

// whether we're interacting with something the world
var private bool fInteractingWithMeterUseTrigger;

var input byte bSkill;

var private bool bPreservedPersonSetting;

// kiosk stuff
var bool bOldBehindView;
//var transient Weapon fOldWeapon;
var transient Triggers fKioskTrigger;
var string fKioskTriggerTagName;
var float fKioskFOV;
var transient Actor fHQListener;
var transient ZoneInfo fCurrentZoneInfo;
var transient ZoneInfo fPrevZoneInfo;
var float fKioskOnDelay;
var float fKioskOffDelay;
var float fKioskOpTicks;
var transient B9_MenuInteraction Factory;
var class<B9_MenuInteraction> FactoryClass;
var class<B9_MenuInteraction>	fPDAClass;
var bool bNVTestOn;

var private EVisionMode		fVisionMode;

var	B9MP_GameClient			fGameClient;
var B9MP_Client				fClient;
var B9MP_ClientBrowser		fClientBrowser;


var PlayerCameraManager		PCamera;
var float					FadeDistance;
var bool					bAlphaExternModified;

var Sound SniperZoomOut;
var Sound SniperZoomIn;

var float fNextUpdateTime;

var int fSkinIndexCopy; // need to remember this in controller for MP

var bool fShowScores;

const kFadeMaxDist = 135;
const kFadeMinDist = 25;

replication
{
	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ShowStandardKiosk,ShowNanoCalKiosk,ShowIntrinsicSkillDisplay, ShowLocationMessage,
		ShowMissionKitKiosk, ShowInteraction, SetKioskView, ResetKioskView, ShowDepotPanel,
		ShowCountdownTimer;

	// Functions client can call.
	reliable if( Role<ROLE_Authority )
		ExitKioskMode, ServerJoeTest;
}

event PreBeginPlay()
{
	Super.PreBeginPlay();
	fShowScores = false;

	fLastVelocity = vect(0,0,0);
	fDelayedJumpTime = 0;

	/*
	PCamera	= new(none) class'PlayerCameraManager';
	PCamera.CameraLocation = Location;
	PCamera.CameraRotation = Rotation;
	PCamera.Init( Self );
	*/
}

event PostBeginPlay()
{
	local String url;
	local B9_PlayerController pc;
	local class<B9_MenuPDA_Menu> pda;
	local B9_MenuInteraction mi;
	local String winSubStr;
	local int winStartPos;
	local int winEndPos;
	local String winChar;
	local int charPos;
	local string str;
	
	Super.PostBeginPlay();

	SetViewTarget(Pawn);
	if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
	{
		if ( (Pawn != None) && !Pawn.bDeleteMe )
		{
			log( "SetViewTarget(Pawn);" );
			SetViewTarget(Pawn);
		}
		else
		{
			log( "SetViewTarget(self);" );
			SetViewTarget(self);
		}
	}

	fResetHUD = true;
	
	// Figure out if the scores should be shown
	url = Level.GetLocalURL(); 
	Log( "ZD: Url = " $ url );
	if( InStr( url, "e1hq" ) >= 0 )
	{
		winStartPos = InStr( url, "win=" );
		if( winStartPos >= 0 )
		{
			fShowScores = true;
		}
	}
}


/*
event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	if ((!bBehindView) || (bInterPolating))
	{
		if (bInterPolating)
			SetViewTarget(Self);
		Super.PlayercalcView(ViewActor,CameraLocation,CameraRotation);
		return;
	}

	if ((ViewTarget == none) || ViewTarget.bDeleteMe)
	{
		if ((Pawn != none) && !Pawn.bDeleteMe)
			SetViewTarget(Pawn);
		else
			SetViewTarget(Self);
	}

	
	ViewActor = ViewTarget;

//	PCamera.CameraTick();
	CameraLocation = PCamera.CameraLocation + ViewTarget.PrePivot;
	CameraRotation = PCamera.CameraRotation;
}
*/

function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local B9_BasicPlayerPawn P;
	P = B9_BasicPlayerPawn( Pawn );
	if( P == None || P.fGuidedTarget == None )  
	{
		return GetViewRotation();
	}
	return GetEularAngles( P.fGuidedTarget.Location - Pawn.Location );
}

simulated function UpdateTargetLock( float DeltaTime )
{
	local vector	X, Y, Z;
	local float		targetDistance;
	local Rotator	rotToTarget;
	local vector	fireStart;
	local B9_BasicPlayerPawn P;
	local Vector	HitLocation, HitNormal;

	P = B9_BasicPlayerPawn( Pawn );
	if( P == None || P.fGuidedTarget == None )  
	{
		return;
	}

	// If this target is dead, break the lock
	//
	if( P.fGuidedTarget.Health <= 0 )
	{
		P.fGuidedTarget = None;
		return;
	}

	// If the angle between our rotation and the target position is
	// too great, break the lock
	//
	rotToTarget		= GetEularAngles( P.fGuidedTarget.Location - Pawn.Location );
	//log( "angle diff: "$VSize( vector( rotToTarget ) - vector( Pawn.Rotation ) ) );
	if( VSize( vector( rotToTarget ) - vector( Pawn.Rotation ) ) > 0.3 )
	{
		P.fGuidedTarget = None;
		return;
	}

	// If we don't have a clear shot to the target, break the lock
	//
	if( Trace( HitLocation, HitNormal, P.fGuidedTarget.Location, Pawn.Location, true ) != P.fGuidedTarget )
	{
		P.fGuidedTarget = None;
	}
}


function FadeOutTarget( vector camPos )
{
	local float dist;
	
	if( fCloakState != kUnCloaked )
	{
		return;
	}
	
	dist = VSize( camPos - Pawn.Location );
	if ( dist < kFadeMaxDist )
	{
		dist -= kFadeMinDist;
		if ( dist < 0 )
		{
			dist = 0;
		}
		Pawn.AdjustAlphaFade( 128 * dist / ( kFadeMaxDist - kFadeMinDist ) );
		//log( "fading: "$128 * dist / ( kFadeMaxDist - kFadeMinDist ) );
	}
	else
	{
		Pawn.RemoveColorModifierSkins();
	}
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector HitLocation,HitNormal, EndTrace, StartTrace;
	local actor a;
	
	if( Pawn == None )
	{
		Super.CalcBehindView( CameraLocation, CameraRotation, Dist );
		return;
	}

	CameraRotation		= Rotation;
	Dist				=  190.0;
	StartTrace			= Pawn.Location;
	EndTrace			= Pawn.Location - Dist * vector(CameraRotation);
	EndTrace.Z			+= 115.0;

	a = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, vect(10,10,10) );
	if( a == None || a == Pawn || a == Self )
	{
		CameraLocation = EndTrace;
	}
	else
	{
		CameraLocation = HitLocation;
	}

	if( CameraLocation.Z < Pawn.Location.Z + 20 )
	{
		CameraLocation.Z = Pawn.Location.Z + 20;
	}
	
	/////////////////////////////////////
	// Start Shaking
	// Christian R. 
	// Added shaking to 3rd person view
	//
	CameraLocation += ShakeOffset;
	// End Shaking

	FadeOutTarget( CameraLocation );
}


function rotator GetViewRotation()
{
//	if ( bBehindView && (Pawn != None) )
//		return Pawn.Rotation;
	return Rotation;
}

exec function KillShadows()
{
	local Pawn aPawn;
	
	log( "SCD:  Kill Shadows!" );
	
	foreach AllActors( class'Pawn', aPawn )
	{
//		aPawn.KillShadow();
/*		if ( aPawn.Shadow != None )
		{
			aPawn.Shadow.Destroy();
		}
		*/
	}
}

exec function B9Debug( String mode )
{
	if ( mode == "targetinfo" )
	{
		B9_HUD( myHUD ).fTargetingReticule.B9Debug( "info" );
	}
	else
	if ( mode == "playerinfo" )
	{
		B9_HUD( myHUD ).fHealthPanel.B9Debug( "info" );
	}
	else
	if ( mode == "targetingskill" )
	{
		B9_HUD( myHUD ).fTargetingReticule.B9Debug( "skill" );
	}
}

// This should probably be defigned elsewhere so that it can be used by other classes
function Rotator GetEularAngles( vector direction )
{
	local vector up, right;
	local float size;

	up = vect(0,0,1);
	size = VSize( direction );
	if ( size < 0.0001 )
	{
		size = 0.0001;
	}
	direction /= size;

	right = up Cross direction;
	return OrthoRotation( direction, right, up );
}



event PreClientTravel()
{
/*
var B9MP_Client				fClient;
var B9MP_ClientBrowse		fClientBrowser;
*/
	local class<B9MP_GameClient> fGameClientClass;
	local class<B9MP_Client> fClientClass;
	local class<B9MP_ClientBrowser> fClientBrowserClass;
	local String onlinePkgNameSuffix;
	
	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}

	log( "B9_PlayerController::PreBeginPlay" );

	if ( IsPlatformXBox() )
	{
		fGameClientClass = class<B9MP_GameClient>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_GameClient_" $ onlinePkgNameSuffix, class'Class'));
		fGameClient = Spawn( fGameClientClass );
		if(fGameClient.JoinGame() == kFailure)
		{
			fGameClient.Destroy();
			fGameClient = None;
		}
	}

	// KMYNF: IMPORTANT!!!  This MUST change before we go split screen, as there will be more than one B9MP_Client class!!!!!
	if ( fClient == None )
	{
		ForEach AllActors( class'B9MP_Client', fClient )
		{
			break;
		}

		if ( fClient == None )
		{
			fClientClass = class<B9MP_Client>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_Client_" $ onlinePkgNameSuffix, class'Class'));
			fClient = Spawn( fClientClass );
		}
	}

	// KMYNF: IMPORTANT!!!  This MUST change before we go split screen, as there will be more than one B9MP_ClientBrowser class!!!!!
/*
	if ( fClientBrowser == None )
	{
		ForEach AllActors( class'B9MP_ClientBrowser', fClientBrowser )
		{
			break;
		}

		if ( fClientBrowser == None )
		{
			fClientBrowserClass = class<B9MP_ClientBrowser>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ClientBrowser_" $ onlinePkgNameSuffix, class'Class'));
			fClientBrowser = Spawn( fClientBrowserClass );
		}

		if ( fClientBrowser != None )
		{
			fClientBrowser.fClientOwner = fClient;
		}
	}
*/
}

event NotifyLevelChange()
{
	Log("B9_PlayerController.NotifyLevelChange");
	
	Super.NotifyLevelChange();
	if (Factory != None)
		Factory.PopAllB9MenuInteractions(self, self.Player);
	SavepointLevel();
}

function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
	if ( Enemy == Other )
		Enemy = None;

	if (Killed == self)
		B9_PlayerPawn(Pawn).CleanupAfterKilled();
}

function Possess( Pawn aPawn )
{
	local B9_PlayerPawn b9_player_pawn;
	local Inventory Inv;
	local class<Inventory> DefaultSkill;
	local B9_Skill hacking_B9Skill;

	Super.Possess( aPawn );

	/*
	b9_player_pawn = B9_PlayerPawn( Pawn );

	if( b9_player_pawn != none)
	{
		// Create inventory browser was changed to ignore attempts to create it twice.
		// This should reduce the network traffic in multiplayer games (the only time this needs to be called)
		// by only calling one function instead of two
		b9_player_pawn.CreateInventoryBrowser();

		
		DefaultSkill = class<Inventory> ( DynamicLoadObject("B9NanoSkills.skill_Hacking", class'Class') );
		// Gain the Default skills if we don't have it already

		if ( DefaultSkill != None && b9_player_pawn.FindInventoryType( DefaultSkill ) == None )
		{
			Inv = Spawn( DefaultSkill );
			Inv.GiveTo(b9_player_pawn);
		}
	}
	*/
}

event NotifyAddInventory(inventory NewItem)
{
	local B9_PlayerPawn PP;

	if (Role < ROLE_Authority)
	{
		Log("NotifyAddInventory on client: "$NewItem);

		PP = B9_PlayerPawn(Pawn);
		if (PP.fInventoryBrowser == None)
		{
			PP.CreateInventoryBrowser();
		}
		PP.AddToInventoryBrowser(NewItem);
	}
}

event NotifyDeleteInventory(inventory Item)
{
	if (Role < ROLE_Authority)
	{
		Log("NotifyDeleteInventory on client: "$Item);
		B9_PlayerPawn(Pawn).DeleteFromInventoryBrowser(Item);
	}
}

//-----------------------------------------------------------------------------
// Animation functions

simulated event AnimEnd(int Channel)
{
	Pawn.AnimEnd(Channel);
	Super.AnimEnd(Channel);
}

simulated function ShowDepotPanel(int kind, optional int current, optional int full)
{
	local B9_HUD	b9HUD;

	b9HUD = B9_HUD(myHUD);
	if ( b9HUD != None )
	{
		b9HUD.ShowDepotPanel(kind, current, full);
	}
}

simulated function ShowCountdownTimer(bool running, int currentSeconds, int alertSeconds,
									  sound normalTick, sound alertTick)
{
	local B9_HUD	b9HUD;

	b9HUD = B9_HUD(myHUD);
	if ( b9HUD != None )
	{
		b9HUD.ShowCountdownTimer(running, currentSeconds, alertSeconds, normalTick, alertTick);
	}
}
				   
event Trigger( Actor Other, Pawn EventInstigator )
{
	//local B9_HUD	b9HUD;
	local B9_CalibrationMaster calibrator;
	local B9_DepotTrigger Depot;
	local B9_CountdownTimer CDTimer;
	local int Kind;

	//Log( "B9_PlayerController.Trigger:"$Other );

	calibrator = B9_CalibrationMaster(Other);
	if (calibrator != None)
	{
		calibrator.ApplyCalibrations(B9_AdvancedPawn(Pawn));
		B9_AdvancedPawn(Pawn).ApplyModifications();

	/*
		// this doesn't work in MP and is probably obsolete anyway
		b9HUD = B9_HUD(myHUD);
		if ( b9HUD != None && b9HUD.fAttributesPanel != None )
		{
			b9HUD.fAttributesPanel.fCharacterStrength = B9_PlayerPawn(Pawn).fCharacterStrength;
			b9HUD.fAttributesPanel.fCharacterDexterity = B9_PlayerPawn(Pawn).fCharacterDexterity;
			b9HUD.fAttributesPanel.fCharacterAgility = B9_PlayerPawn(Pawn).fCharacterAgility;
			b9HUD.fAttributesPanel.fCharacterHealth = B9_PlayerPawn(Pawn).fCharacterConstitution;
		}
	*/
		return;
	}

	Depot = B9_DepotTrigger(Other);
	if (Depot != None)
	{
		ShowDepotPanel(Depot.GetKind(), Depot.CurrentAmount, Depot.ResourceAmount);
		return;
	}

	CDTimer = B9_CountdownTimer(Other);
	if (CDTimer != None)
	{
		ShowCountdownTimer(CDTimer.fRunning, int(CDTimer.fCurrentTicks + 0.50f), CDTimer.fAlertSeconds,
			CDTimer.fNormalTickSound, CDTimer.fAlertTickSound);
		return;
	}
}

event Untrigger( Actor Other, Pawn EventInstigator )
{
	local B9_HUD	b9HUD;
	local B9_DepotTrigger Depot;

	//Log( "B9_PlayerController.Untrigger:"$Other );

	Depot = B9_DepotTrigger(Other);
	if (Depot != None)
	{
		ShowDepotPanel(-1);
		return;
	}
}

function HandleWalking()
{
	// ZD Do not call the parent HandleWalking, since it seems to use the concept of a run toglle, and we do not
}


exec function ForceReload()
{
	local UseTrigger		trg;
	local ScriptedSequence	seq;

	if( Pawn == None || Pawn.Health <= 0 )
	{
		return;
	}

	ForEach Pawn.TouchingActors( class'UseTrigger', trg )
	{
		if( trg != None )
		{
            return;
		}
	}
	ForEach Pawn.TouchingActors( class'ScriptedSequence', seq )
	{
		if( seq != None )
		{
            return;
		}
	}

	if ( (Pawn != None) && (Pawn.Weapon != None) )
	{
		Pawn.Weapon.ForceReload();
	}
}

exec function Use()
{
	local B9_PlayerPawn P;
	local B9_HUDDebugMenu debugMenu;
	local UseTrigger		trg;
	local ScriptedSequence	seq;
	local bool				bShouldDoUse;

	bShouldDoUse = false;

	if( Pawn == None || Pawn.Health <= 0 )
	{
		return;
	}

	ForEach Pawn.TouchingActors( class'UseTrigger', trg )
	{
		if( trg != None )
		{
            bShouldDoUse = true;
			break;
		}
	}
	ForEach Pawn.TouchingActors( class'ScriptedSequence', seq )
	{
		if( seq != None )
		{
            bShouldDoUse = true;
			break;
		}
	}

	debugMenu = B9_HUD( myHUD ).fDebugMenu;
	
	if ( debugMenu.fVisible )
	{
		debugMenu.Select();
	}
	else if( bShouldDoUse )
	{	
		P = B9_PlayerPawn( Pawn );
		if( P == None || P.IsPerformingExclusiveAction() )
		{
			return;
		}

		B9_BasicPlayerPawn(Pawn).PlayUseSwitch();
	}
}

function bool AmIInteracting()
{
	return fInteractingWithMeterUseTrigger;
}

event ZoneChange( ZoneInfo NewZone )
{
	fPrevZoneInfo = fCurrentZoneInfo;
	fCurrentZoneInfo = NewZone;
	
	//Log("ZC: PZ="$fPrevZoneInfo.Name$" CZ="$fCurrentZoneInfo.Name);
}



exec function AbortMission()
{	
/*
	B9_PlayerPawn(Pawn).fShowMenus = true;
	B9_PlayerPawn(Pawn).fInGame = false;
//	Level.Game.SendPlayer(self, "B9Entry.b9");
	ClientTravel( "B9Entry.b9", TRAVEL_Absolute, true );

	// Empty Out the inventory

	Pawn.Weapon = None;
	Pawn.PendingWeapon = None;
	Pawn.SelectedItem = None;

	while ( Pawn.Inventory != None )
	{
		Pawn.Inventory.Destroy();
	}
*/
}

exec function AcceptKey()
{
}

exec function RejectKey()
{
}
/* ShowUpgradeMenu()
Event called when the engine version is less than the MinNetVer of the server you are trying
to connect with.  
*/ 
event ShowUpgradeMenu();

function CreateCamera()
{
	local Actor target;
	local B9_CameraPawn camera;

	return;

	if ( fCamera != None )
	{
		if( fCamera.Target != fCamera && Pawn != None)
		{
			fCamera.SetTarget(Pawn);
		}
		return;
	}

 
	if ( Pawn == None )
	{
		target = self;
	}
	else
	{
		target = Pawn;
	}

	// Create the 3rd person camera	
	camera = Spawn( class 'B9_CameraPawn', target,, target.Location, target.Rotation );
	fCamera = Spawn( class 'B9_CameraController2', target,, target.Location, target.Rotation );	// Not sure if this is correct
	if ( camera == None )
	{
		log( "B9_CameraPawn not created" );
	}
	if ( fCamera == None )
	{
		log( "B9_CameraController not created" );
	}
	fCamera.Possess( camera );
	fCamera.SetTarget(target);
}


///////////////////////////////////////////
// View controls
//

exec function CamModeThirdPerson()
{
	if( !bBehindView )
	{
		bBehindView = true;
	}
}

exec function CamModeFirstPerson()
{
	if( bBehindView )
	{
		bBehindView = false;
	}
}
exec function ZoomScope()
{
	local B9_AdvancedPawn	playerPawn;
	local B9WeaponBase		playerWeapon;


	playerPawn	= GetAdvancedPawn();
	if ( ( playerPawn != None ) && ( GetVehiclePawn() == None ) )
	{
		playerWeapon	= B9WeaponBase( playerPawn.Weapon );
		if ( ( playerWeapon != None ) && ( playerWeapon.fHasScope ) )
		{
			if ( bBehindView )
			{
				CamModeFirstPerson();
			}
			else
			{
				CamModeThirdPerson();
			}
		}
	}
}
///////////////////////////////////////////
// Misc. controls
//

exec function HideHUD()
{
	local B9_HUD b9HUD;
	
	b9HUD = B9_HUD(myHUD);
	if( b9HUD != None )
	{
		b9HUD.fHideHUD = !b9HUD.fHideHUD;
	}
}

///////////////////////////////////////////
// Inventory Controls
//

exec function InventoryUp()
{
	local B9InventoryBrowser invBrs;
	local B9_HUDDebugMenu debugMenu;
	
	debugMenu = B9_HUD( myHUD ).fDebugMenu;
	
	if ( debugMenu.fVisible )
	{
		debugMenu.PreviousItem();
	}
	else
	{	
		invBrs = B9_PlayerPawn(Pawn).fInventoryBrowser;
		if( invBrs != none )
		{
			if( invBrs.GetSelectedColumn() == 0 && Pawn.Weapon.IsInState( 'Reloading' ) )
			{
				return;
			}
			invBrs.ScrollUp();
		}
	}
}

exec function InventoryDown()
{
	local B9InventoryBrowser invBrs;
	local B9_HUDDebugMenu debugMenu;
	
	debugMenu = B9_HUD( myHUD ).fDebugMenu;
	
	if ( debugMenu.fVisible )
	{
		debugMenu.NextItem();
	}
	else
	{
		invBrs = B9_PlayerPawn(Pawn).fInventoryBrowser;
		if( invBrs != none )
		{
			if( invBrs.GetSelectedColumn() == 0 && Pawn.Weapon.IsInState( 'Reloading' ) )
			{
				return;
			}
			invBrs.ScrollDown();
		}
	}
}

exec function InventoryLeft()
{
	local B9InventoryBrowser invBrs;
	local B9_HUDDebugMenu debugMenu;
	
	debugMenu = B9_HUD( myHUD ).fDebugMenu;
	
	if ( debugMenu.fVisible )
	{
		debugMenu.PreviousCategory();
	}
	else
	{
		invBrs = B9_PlayerPawn(Pawn).fInventoryBrowser;
		if( invBrs != none )
		{
			invBrs.ScrollLeft();
		}
	}
}

exec function InventoryRight()
{
	local B9InventoryBrowser invBrs;
	local B9_HUDDebugMenu debugMenu;
	
	debugMenu = B9_HUD( myHUD ).fDebugMenu;
	
	if ( debugMenu.fVisible )
	{
		debugMenu.NextCategory();
	}
	else
	{
		invBrs = B9_PlayerPawn(Pawn).fInventoryBrowser;
		if( invBrs != none )
		{
			invBrs.ScrollRight();
		}
	}
}

exec function InventoryDrop()
{
	if( Pawn != None && Pawn.Health > 0 )
	{
        B9_PlayerPawn(Pawn).InventoryDrop();
	}
}

///////////////////////////////////////////
// Skill controls
//

exec function ActivateSkill()
{

	local B9_PlayerPawn P;
	local B9_Skill		skill;

	/*
	if( TakingAHit() )
	{
		return;
	}
	*/

	P = B9_PlayerPawn( Pawn );
	if( P != None )
	{
		skill =  P.fSelectedSkill;

		if( skill != None )
		{
			skill.Activate();
		}
	}
}


///////////////////////////////////////////
// Weapon controls
//

exec function PutDownGun()
{
	/*
	if( TakingAHit() )
	{
		return;
	}
	*/

	if ( Pawn.Weapon != None )
	{
		Pawn.Weapon.PutDown();
		Pawn.PendingWeapon = None;
		Pawn.Weapon = None;
	}
}

exec function NextCameraDist()
{
	fCamera.NextCameraDist();
}

exec function Pause( optional String startingMenu )
{
	if (Level.Pauser != None)
	{
		SetPause(false);
	}
	else
	{
		Log("B9_PlayerController.Pause");
		B9_HUD(myHUD).AddPauseMenu( self, startingMenu);
		SetPause(true);
	}
}


// The player wants to fire.
exec function Fire( optional float F )
{
	/*
	if( TakingAHit() )
	{
		return;
	}
	*/

	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}

	if( Pawn.Weapon!=None )
	{
		Pawn.Weapon.bPointing = true;
		Pawn.Weapon.Fire(F);
		if( Target != None )
		{
            SendTargetAttackWarning( Target, Pawn );
		}
	}
}



// The player wants to AltFire.
exec function AltFire( optional float F )
{
	/*
	if( TakingAHit() )
	{
		return;
	}
	*/

//	bJustAltFired = true;
	if( (Level.Pauser!=None) || (Role < ROLE_Authority) )
	{
//		if( (Role < ROLE_Authority) && (Pawn.Weapon!=None) )
//			bJustAltFired = Pawn.Weapon.ClientAltFire(F);
		if ( Level.Pauser == PlayerReplicationInfo )
			SetPause(False);
		return;
	}
	if( Pawn.Weapon!=None )
	{
		Pawn.Weapon.bPointing = true;
		Pawn.Weapon.AltFire(F);
	}
	else
	{
	}

	// Warn the target that they are being fired upon.
	SendTargetAttackWarning( Target, Pawn );
}


exec function Jump( optional float F )
{
	local B9_BasicPlayerPawn P;

	P = B9_BasicPlayerPawn( Pawn );
	if( P == None || P.fJustFellSoft || P.fJustFellModerate || P.fJustFellHard )
	{
		return;
	}

	bPressedJump = true;
}


event TravelPostAccept()
{
	local Inventory Inv;
	local class<Inventory> DefaultSkill;
	local B9_Skill hacking_B9Skill;
	local B9_PlayerPawn p;

	log("TravelPost Accept Called");
	// This function is only called once
	Super.TravelPostAccept();

	Pawn.ChangedWeapon();

	B9_PlayerPawn( Pawn ).fSelectedSkill = None;

	log( "B9_PlayerController::TravelPostAccept --> Switching Levels" );
}

function SendTargetAttackWarning( Actor target, Pawn attacker )
{
	local Pawn					targetPawn;
	local B9_ArchetypePawnBase	targetArchPawn;
	local Controller			targetArchController;
	local vector				fireDirection;

	targetPawn = Pawn( target );
	if( targetPawn != None )
	{
		targetArchPawn = B9_ArchetypePawnBase( targetPawn );
		if( targetArchPawn != None )
		{
			targetArchController = targetArchPawn.Controller;
			if( targetArchController != None )
			{
				fireDirection = Target.Location - attacker.Location;
				targetArchController.ReceiveWarning( attacker, attacker.Weapon.AmmoType.ProjectileClass.Default.Speed, fireDirection );
			//	log( "ALEX: Send ReceiveWarning" );
			}
		}
	}
}

function bool SniperZoom()
{
	if ( GetStateName() != 'PlayerSniping' && !bBehindView && B9WeaponBase(Pawn.Weapon) != None && 
		B9WeaponBase(Pawn.Weapon).fHasScope && B9WeaponBase(Pawn.Weapon).fZoomed )
	{
		return true;
	}
	else
	{
		return false;
	}
}

event PlayerTick( float DeltaTime )
{
	local B9_HUD b9HUD;
	local int winStartPos;
	local int winEndPos;
	local String winChar;
	local int charPos;
	local string str, url;

	if( Pawn != None )
	{
		if( fShowScores )
		{	
			url = Level.GetLocalURL();
			if( InStr( url, "e1hq" ) >= 0 )
			{
				winStartPos = InStr( url, "win=" );
				if( winStartPos >= 0 )
				{
					winEndPos = winStartPos + Len( "win=" );
					charPos   = winEndPos;

					while( winEndPos < Len( url ) )
					{
						winChar = Mid( url, winEndPos, 1 );
						if( winChar == "$" || winChar == "#" )
							break;

						winEndPos++;
					}

					str = "Mission" $ Mid( url, charPos, winEndPos-charPos );
					B9_BasicPlayerPawn( Pawn ).fCharacterConcludedMissionString = Localize( "MissionTitles", str, "B9SaveGame" );
					Pause( "B9Menus.B9_PDA_MissionHistory" );
				}
			}
			fShowScores = false;
		}
		if ( Pawn.Weapon != None )
		{
			if ( GetStateName() != 'PlayerSniping' && !bBehindView && B9WeaponBase(Pawn.Weapon) != None && 
				B9WeaponBase(Pawn.Weapon).fHasScope )
			{
				B9WeaponBase(Pawn.Weapon).fZoomed = true;
				SetFOV( DefaultFOV / B9WeaponBase(Pawn.Weapon).fScopeMagnify );
			}
			else
			{
				if ( B9WeaponBase(Pawn.Weapon) != None && B9WeaponBase(Pawn.Weapon).fHasScope )
				{
					B9WeaponBase(Pawn.Weapon).fZoomed = false;
					B9WeaponBase(Pawn.Weapon).fScopeMagnify = 1;
				}
				else
					if ( fKioskTrigger == None )
					{
						CamModeThirdPerson();
					}
					SetFOV(DefaultFOV);
			}
		}
		else
		if ( fKioskTrigger == None )
		{
			CamModeThirdPerson();
		}

		if( PCamera != None )
		{
			PCamera.CameraTick( DeltaTime );
		}
	}

	// Find out if it's time to execute a delayed jump action
	if( fDelayedJumpTime > 0 )
	{
		if( ( fDelayedJumpTime -= DeltaTime ) < 0 )
		{
			//Log( "Starting actual jump" );

			Super.Jump( 0.000 );	//ANF@@@ Save off the optional F param from the orginal call.
		}
	}

	// Update our HUD if necessary
	if ( fResetHUD )
	{
		b9HUD = B9_HUD(myHUD);
		if ( b9HUD != None && b9HUD.fAttributesPanel != None && B9_PlayerPawn(Pawn) != None)
		{
			// Load the HUD attributes panel
			b9HUD.fAttributesPanel.fCharacterName = B9_PlayerPawn(Pawn).fCharacterName;
			b9HUD.fAttributesPanel.fCharacterOccupation = B9_PlayerPawn(Pawn).fCharacterOccupation;
			b9HUD.fAttributesPanel.fCharacterCompany = B9_PlayerPawn(Pawn).fCharacterCompany;
			b9HUD.fAttributesPanel.fCharacterStrength = B9_PlayerPawn(Pawn).fCharacterStrength;
			b9HUD.fAttributesPanel.fCharacterDexterity = B9_PlayerPawn(Pawn).fCharacterDexterity;
			b9HUD.fAttributesPanel.fCharacterAgility = B9_PlayerPawn(Pawn).fCharacterAgility;
			b9HUD.fAttributesPanel.fCharacterHealth = B9_PlayerPawn(Pawn).fCharacterConstitution;

			fResetHUD = false;
		}

		if ( myHUD == None )
		{
			log( "B9_PlayerController::PlayerTick --> myHUD is NONE" );
		}
		else if ( b9HUD == None )
		{
			log( "B9_PlayerController::PlayerTick --> b9HUD is NONE" );
		}
	}

	CreateCamera();

	super.PlayerTick(DeltaTime);

	fAwayFromCamera = aForward;
	fWithCamera = aStrafe;

	UpdateCameraFX();

	// Update cloak
	UpdateCloak( DeltaTime );

	// Update targeting
	UpdateTargetLock( DeltaTime );
}


function B9_AdvancedPawn GetAdvancedPawn()
{
	if ( Pawn != None )
	{
		if ( B9_AdvancedPawn( Pawn ) != None )
		{
			return B9_AdvancedPawn( Pawn );
		}
		else
		if ( B9_Vehicle( Pawn ) != None )
		{
			if ( B9_AdvancedPawn( B9_Vehicle( Pawn ).Driver ) != None )
			{
				return B9_AdvancedPawn( B9_Vehicle( Pawn ).Driver );
			}
		}
		if ( B9_KVehicle( Pawn ) != None )
		{
			if ( B9_AdvancedPawn( B9_KVehicle( Pawn ).Driver ) != None )
			{
				return B9_AdvancedPawn( B9_KVehicle( Pawn ).Driver );
			}
		}
	}

	return None;
}

function float GetTurnResponseRate()
{
	local float				turnResponseRate;
	local B9_AdvancedPawn	advancedPawn;


	turnResponseRate	= 2;

	advancedPawn	= GetAdvancedPawn();
	if ( advancedPawn != None )
	{
		turnResponseRate	+= 6 * advancedPawn.GetTargetingSkill() / 100.0;
	}

	return turnResponseRate;
}

function float GetTurningAngle( float currentAngle, float targetAngle, float DeltaTime )
{
	local float	angleDiff;
	local float	turningAngle;


	angleDiff	= ( targetAngle & 65535 ) - ( currentAngle & 65535 );
	if ( angleDiff > 32768 )
	{
		angleDiff = -( 65535 - angleDiff );
	}
	else
	{
		if ( angleDiff < -32768 )
		{
			angleDiff = 65535 + angleDiff;
		}
	}

	turningAngle	= currentAngle + angleDiff * DeltaTime * GetTurnResponseRate();

	return turningAngle;
}

function bool TargetLockAcquired()
{
	bLockTargetDesired = true;
	if( Target == None )
	{
		Target = Pawn;
	}
	return true;

	if ( Pawn.Weapon != None && Target != None && bLockTargetDesired )
	{
		if ( fCamera.GetStateName() != 'TargetLock' )
		{
			fCamera.GotoState( 'TargetLock' );
		}
		return true;
	} 
	else
	{
		if ( fCamera.GetStateName() == 'TargetLock' )
		{
			fCamera.GotoState( 'Orbiting' );
		}
		return false;
	}
}






function HoldForSpecialAnimation( B9_Pawn.ESpecialAnimation animation, name prevState )
{
	fSpecialAnimation = animation;
	fPrevState = prevState;

	GotoState( 'PlayingSpecialAnimation' );
}

exec function LockTarget( bool lock )
{
	bLockTargetDesired	= lock;
}

exec function CycleTarget( int cycle )
{
	if ( cycle > 0 )
	{
		fCycleTarget	= 1;
	}
	else
	if ( cycle < 0 )
	{
		fCycleTarget	= -1;
	}
	else
	{
		fCycleTarget	= 0;
	}
}

function UpdateCameraFX()
{
	local int	EffectIndex;

	for( EffectIndex = 0; EffectIndex < CameraEffects.Length; EffectIndex++ )
	if( CameraEffects[EffectIndex] != none && CameraEffects[EffectIndex].Alpha <= 0 )
	{
//		CameraEffects[EffectIndex].Destroy();
		CameraEffects.Remove( EffectIndex, 1 );
	}
}

/////////////////////////////////////////////////////////////////////////////////////
// state PlayingSpecialAnimation
// Stop the player to do a scripted animation
// 
/////////////////////////////////////////////////////////////////////////////////////

state PlayingSpecialAnimation
{
	function PlayerMove( float DeltaTime )
	{
		// Update camera position
		fCamera.SetTurn( aTurn * 32, DeltaTime );

		fCamera.SetPitch( aLookUp * 32, DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0) );
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0) );
		
		bPressedJump = false;
	}

	function PlayAnimation()
	{
		local B9_Pawn b9Pawn;

		b9Pawn = B9_Pawn(Pawn);

		if ( b9Pawn != None )
		{
			b9Pawn.PlaySpecialAnimation(fSpecialAnimation);
		}
	}

Begin:
	PlayAnimation();
	FinishAnim();
	GotoState( fPrevState );
}

function int CompareTargets( B9_HUD.tTargetItem target1, B9_HUD.tTargetItem target2 )
{
	// closer to view ?
	if ( target1.fBearing > target2.fBearing )
	{
		return -1;
	}
	else
	if ( target1.fBearing < target2.fBearing )
	{
		return 1;
	}
	else
	// shorter range ?
	if ( target1.fRange < target2.fRange )
	{
		return -1;
	}
	else
	if ( target1.fRange > target2.fRange )
	{
		return 1;
	}

	return 0;
}

function SortTargets( out array< B9_HUD.tTargetItem > targetList, int maxTargetCount )
{
	local int	itTarget;
	local int	itSort;
	local array< B9_HUD.tTargetItem >	targetListSorted;


	for ( itTarget = 0; itTarget < targetList.Length; ++itTarget )
	{
		for ( itSort = 0; itSort < targetListSorted.Length; ++itSort )
		{
			if ( CompareTargets( targetList[ itTarget ], targetListSorted[ itSort ] ) < 0 )
			{
				// insert the closer target
				targetListSorted.Insert( itSort, 1 );
				targetListSorted[ itSort ]	= targetList[ itTarget ];
				break;
			}
		}

		// add to tail ?
		if ( itSort == targetListSorted.Length )
		{
			targetListSorted.Length		= targetListSorted.Length + 1;
			targetListSorted[ itSort ]	= targetList[ itTarget ];
		}
	}

	// remove the excess items
	if ( targetListSorted.Length > maxTargetCount )
	{
		targetListSorted.Length	= maxTargetCount;
	}

	// copy the list
	targetList	= targetListSorted;
}

function CheckTarget( out array< B9_HUD.tTargetItem > targetList, Actor newTarget, vector fireStart, vector hitLocation )
{
	local int		itTarget;
	local int		HUDActions;
	local float		targetRange;
	local vector	aim;
	local vector	targetVector;
	local float		targetBearing;
	local float		FOV;


	if ( ( newTarget != None ) && ( newTarget != Pawn ) && ( ( Pawn( newTarget ) == None ) || ( Pawn( newTarget ).Health > 0 ) ) )
	{
		HUDActions			= newTarget.GetHUDActions( Pawn );

		// don't bother with non-interactive targets
		if ( HUDActions == kHUDAction_None )
		{
			return;
		}

		// in view ?
		FOV				= 5.0;//@@ in degrees; modify FOV here
		aim				= Vector( GetViewRotation() );
		targetVector	= newTarget.Location - fireStart;
		targetBearing	= Normal( targetVector ) Dot aim;

		if ( targetBearing < ( FOV / 180.0 ) )
		{
			return;
		}

		targetRange		= VSize( fireStart - hitLocation );

		itTarget			= targetList.Length;
		targetList.Length	= itTarget + 1;

		targetList[ itTarget ].fActor		= newTarget;
		targetList[ itTarget ].fHitLocation	= hitLocation;
		targetList[ itTarget ].fRange		= targetRange;
		targetList[ itTarget ].fBearing		= targetBearing;
		targetList[ itTarget ].fLocked		= false;
		targetList[ itTarget ].fTimeLocked	= 0;
	}
}

function FindTargets( out array< B9_HUD.tTargetItem > targetList )
{
	local vector	X, Y, Z;
	local Pawn				newTarget;
	local vector			traceEnd;
	local vector			traceStart;
//	local vector			traceExtent;
	local float				weaponRange;
	local B9_AdvancedPawn	B9_Advanced;
//	local float				targetingSkill;
	local vector			hitLocation;
	local vector			hitNormal;


	GetAxes( Pawn.GetViewRotation(), X, Y, Z );

	weaponRange		= Pawn.Weapon.MaxRange;
	traceStart		= Pawn.Weapon.GetFireStart( X, Y, Z );
	traceEnd		= traceStart + X * weaponRange;
//	traceExtent		= vect( 1, 1, 1 ) * targetingSkill;
//	B9_Advanced = B9_AdvancedPawn( Pawn );
//	if (  B9_Advanced != None )
//	{
//		targetingSkill	= 16 + ( 32 * B9_Advanced.GetTargetingSkill() / 100.0 );
//	}

	// using trace extent
	//foreach TraceActors( class 'Pawn', newTarget, hitLocation, hitNormal, traceEnd, traceStart, traceExtent )
	// using visible radius
	foreach Pawn.VisibleActors( class'Pawn', newTarget, weaponRange, traceStart )
	{
		// using trace extent
		//CheckTarget( targetlist, newTarget, traceStart, hitLocation );
		// using visible radius
		CheckTarget( targetList, newTarget, traceStart, newTarget.Location );
	}
}

function BuildTargetList( out array< B9_HUD.tTargetItem > targetList )
{
	local vector	X, Y, Z;
	local int					i;
	local int					j;
	local B9_HUD.tTargetItem	oldTarget;
	local int					oldTargetIndex;
	local vector				hitLocation;
	local vector				hitNormal;
	local Actor					hitActor;
	local vector				traceEnd;
	local vector				traceStart;
	local float					lockTTL;
	local int					maxTargetCount;
	local float					weaponRange;
	local B9_AdvancedPawn		B9_Advanced;

	if (fNextUpdateTime > Level.TimeSeconds)
		return;
	fNextUpdateTime = Level.TimeSeconds + 0.20 + frand()*0.10;

	GetAxes( Pawn.GetViewRotation(), X, Y, Z );

	maxTargetCount	= 10/*@ target count rating goes here*/;
	weaponRange		= Pawn.Weapon.MaxRange;
	traceStart		= Pawn.Weapon.GetFireStart( X, Y, Z );
	traceEnd		= traceStart + X * weaponRange;
	B9_Advanced		= B9_AdvancedPawn( Pawn );
	if (  B9_Advanced != None )
	{
		lockTTL			= 1.0 + ( 2.0 * B9_Advanced.GetTargetingSkill() / 100.0 );
	}

	// store the active locked target in case of a lost lock
	if ( bLockTargetDesired )
	{
		for ( i = 0; i < targetList.Length; ++i )
		{
			if ( ( targetList[ i ].fActor != None ) && targetList[ i ].fLocked && ( Pawn( targetList[ i ].fActor ).Health > 0 ) )
			{
				// still fresh ?
				if ( ( ( targetList[ i ].fTimeLocked + lockTTL ) > Level.TimeSeconds ) )
				{
					oldTarget		= targetList[ i ];
					oldTargetIndex	= i;

					break;
				}
			}
		}
	}

	// clear target list
	targetList.Length					= 0;
	Target								= None;

	// fill target list
	FindTargets( targetList );

	// since the trace must be done for each class separately, we must sort the results
	SortTargets( targetList, maxTargetCount );

	// force old target ? might have lost line-of-sight, and/or the target list changed
	// old target is ALWAYS updated/added
	if ( oldTarget.fActor != None )
	{
		// is old target in the list ?
		for ( i = 0; i < targetList.Length; ++i )
		{
			if ( targetList[ i ].fActor == oldTarget.fActor )
			{
				// refresh the lock
				targetList[ i ].fLocked		= true;
				targetList[ i ].fTimeLocked	= Level.TimeSeconds;

				// move from current to old position
				oldTarget								= targetList[ i ];
				targetList.Remove( i, 1 );
				targetList.Insert( oldTargetIndex, 1 );
				targetList[ oldTargetIndex ]		= oldTarget;

				// mark it as handled
				oldTarget.fActor	= None;

				// need this later
				i	= oldTargetIndex;

				break;
			}
		}

		// old target not found ? add old target to list
		if ( oldTarget.fActor != None )
		{
			hitActor	= Trace( hitLocation, hitNormal, traceEnd, traceStart, true );

			if ( hitActor == oldTarget.fActor )
			{
				oldTarget.fHitLocation	= hitLocation;
				oldTarget.fRange		= VSize( traceStart - hitLocation );
				// refresh the lock since we can still see the target
				oldTarget.fLocked		= true;
				oldTarget.fTimeLocked	= Level.TimeSeconds;
			}
			else
			{
				// must estimate range since we can't see it
				oldTarget.fHitLocation	= oldTarget.fActor.Location;
				oldTarget.fRange		= VSize( traceStart - oldTarget.fActor.Location );
			}

			// insert old target at old position
			targetList.Insert( oldTargetIndex, 1 );
			targetList[ oldTargetIndex ]	= oldTarget;

			// remove the excess items
			if ( targetList.Length > maxTargetCount )
			{
				targetList.Length	= maxTargetCount;
			}

			// need this later
			i	= oldTargetIndex;
		}

		// cycle target ?
		if ( fCycleTarget != 0 )
		{
			if ( targetList.Length > 1 )
			{
				for ( j = i + fCycleTarget; j != i; j += fCycleTarget )
				{
					if ( j < 0 )
					{
						j	= targetList.Length - 1;
					}
					else
					if ( j > ( targetList.Length - 1 ) )
					{
						j	= 0;
					}

					if ( ( targetList[ j ].fActor.GetHUDActions( Pawn ) & kHUDAction_Attack ) == kHUDAction_Attack )
					{
						// unlock old one
						targetList[ i ].fLocked		= false;

						i	= j;

						// lock new one
						targetList[ i ].fLocked		= true;
						targetList[ i ].fTimeLocked	= Level.TimeSeconds;// refresh the lock

						break;
					}
				}
			}
		}

		// store new target
		Target						= targetList[ i ].fActor;
	}
	// no old target
	else
	{
		// lock the first one
		if ( bLockTargetDesired )
		{
			for ( i = 0; i < targetList.Length; ++i )
			{
				if ( ( targetList[ i ].fActor.GetHUDActions( Pawn ) & kHUDAction_Attack ) == kHUDAction_Attack )
				{
					targetList[ i ].fLocked		= true;
					targetList[ i ].fTimeLocked	= Level.TimeSeconds;// lock starts now

					Target						= targetList[ i ].fActor;

					break;
				}
			}
		}
	}

	// always clear this flag
	fCycleTarget	= 0;
}


/////////////////////////////////////////////////////////////////////////////////////
// state PlayerWalking
// Player movement.
// Player Standing, walking, running, falling.
/////////////////////////////////////////////////////////////////////////////////////
state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		local vector X, Y, Z, NewAccel;
		local rotator ViewRotation, OldRotation;
		local float newAccelSize;
		
		/*
		if ( Pawn.Weapon != None )
		{
			BuildTargetList( B9_HUD( MyHud ).fTargets );
		}
		*/
		GetAxes(Pawn.Rotation,X,Y,Z);

		// Update acceleration.
		if ( SniperZoom() )
		{
			NewAccel = aStrafe*Y; 
			
			// cr - If zoomed play zooming sounds. But only when you arent at the end of the zooming 
			//spectrum.
			if (fSniperZoom < 0 && B9WeaponBase(Pawn.Weapon).fScopeMagnify > 1)
			{
				PlaySound(SniperZoomOut, SLOT_None, 1.0,,200);
			}
			else
			{
				if ( fSniperZoom > 0 && B9WeaponBase(Pawn.Weapon).fScopeMagnify != 
					 B9WeaponBase(Pawn.Weapon).fScopeMaxMagnify)
				{
					PlaySound(SniperZoomIn, SLOT_None, 1.0,,200);
				}
			}
					
				
			B9WeaponBase(Pawn.Weapon).fScopeMagnify += fSniperZoom;
			if ( B9WeaponBase(Pawn.Weapon).fScopeMagnify < 1 )
			{
				B9WeaponBase(Pawn.Weapon).fScopeMagnify = 1;
			}
			else if ( B9WeaponBase(Pawn.Weapon).fScopeMagnify > 
				B9WeaponBase(Pawn.Weapon).fScopeMaxMagnify )
			{
				B9WeaponBase(Pawn.Weapon).fScopeMagnify = B9WeaponBase(Pawn.Weapon).fScopeMaxMagnify;
			}
		}
		else
		{
			if( IsPlatformXbox() )
			{
				if( aForward > 0 )
				{
					if( aForward <= 150 )
					{
						aForward = 150;
					}
					else
					{
						aForward = 300;
					}
				}
				else if( aForward < 0 )
				{
					if( aForward >= -150 )
					{
						aForward = -150;
					}
					else
					{
						aForward = -300;
					}
				}

				if( aStrafe > 0 )
				{
					if( aStrafe <= 150 )
					{
						aStrafe = 150;
					}
					else
					{
						aStrafe = 300;
					}
				}
				else if( aStrafe < 0 )
				{
					if( aStrafe >= -150 )
					{
						aStrafe = -150;
					}
					else
					{
						aStrafe = -300;
					}
				}
			}

			NewAccel = aForward*X + aStrafe*Y; 
		}
		NewAccel.Z = 0;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		GroundPitch = 0;	
		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( VSize(NewAccel) < 200 )
		{
			Pawn.bIsWalking = true;
		}
		else
		{
			Pawn.bIsWalking = false;
		}

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, rot(0,0,0) );
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, rot(0,0,0) );

		bPressedJump = false;
	}
}





/////////////////////////////////////////////////////////////////////////////////////
// state PlayerFlying
// Player movement.
// 
/////////////////////////////////////////////////////////////////////////////////////
state PlayerFlying
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		Pawn.bIsWalking = false;
		Super.ProcessMove( DeltaTime, NewAccel, DoubleClickMove, DeltaRot );
	}

	/*
	function PlayerMove( float DeltaTime )
	{
		Super.PlayerMove( DeltaTime );
		if ( Pawn.Weapon != None )
		{
			BuildTargetList( B9_HUD( MyHud ).fTargets );
		}
	}
	*/
}

/////////////////////////////////////////////////////////////////////////////////////
// state PlayerSwimming
// Player movement.
// 
/////////////////////////////////////////////////////////////////////////////////////
state PlayerSwimming
{
	exec function Jump( optional float F )
	{
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		Pawn.bIsWalking = false;
		Super.ProcessMove( DeltaTime, NewAccel, DoubleClickMove, DeltaRot );
	}

	// This function is not currently referenced!!!! (Comment by Joe 5/9/03)
	function bool CheckQuickStop()
	{
		local float d1, d2;
		local vector v1, v2;

		v1 = fLastVelocity;
		v2 = Pawn.Velocity;
		v2.z = 0;
		fLastVelocity = v2;

		if ( Pawn.Physics == PHYS_FALLING )
		{
			return false;
		}

		d1 = VSize(v1);

		if ( d1 < 500 )	// Where we not moving before?
		{
			return false;
		}
		d2 = VSize(v2);

		if ( d2 < 500 )	// Did we stop?
		{
			return false;		// TODO...
		}

		v1 /= d1;
		v2 /= d2;

		if ( ( v1 Dot v2 ) < 0 ) // Did we change directions
		{
			return true;
		}		
		else
		{
			return false;
		}
	}
	
	/*
	function PlayerMove( float DeltaTime )
	{
		Super.PlayerMove( DeltaTime );
		if ( Pawn.Weapon != None )
		{
			BuildTargetList( B9_HUD( MyHud ).fTargets );
		}
	}
	*/
}

/////////////////////////////////////////////////////////////////////////////////////
// state PlayerClimbing
// Player movement.
// 
/////////////////////////////////////////////////////////////////////////////////////
state PlayerClimbing
{
	// No Firing of weapons while climbing	
    exec function Fire(optional float F)
    {
    }
    exec function AltFire(optional float F)
    {
    }

	/*
	function PlayerMove( float DeltaTime )
	{
		Super.PlayerMove( DeltaTime );
		if ( Pawn.Weapon != None )
		{
			BuildTargetList( B9_HUD( MyHud ).fTargets );
		}
	}
	*/
}

state PlayerDriving
{
ignores SeePlayer, HearNoise, Bump;

	exec function Use()
	{
		// pass the "USE" command to the vehicle for exiting
		if ( B9_Vehicle( Pawn ) != None )
		{
			B9_Vehicle( Pawn ).Use();
		}
		else
		if ( B9_KVehicle( Pawn ) != None )
		{
			B9_KVehicle( Pawn ).Use();
		}

		Super.Use();
	}

    event PlayerCalcView( out Actor viewActor, out Vector cameraLocation, out Rotator cameraRotation )
    {
        local vector	view, camLookAt, hitLocation, hitNormal;
        local plane		camView;

		
		viewActor		= ViewTarget;
	    cameraLocation	= ViewTarget.Location;

	    if ( ViewTarget == Pawn )
	    {
		    if ( !bBehindView ) // not drawing car
            {
    		    CalcBehindView( cameraLocation, cameraRotation, cameraDist * ViewTarget.Default.CollisionRadius );
            }
		    else // drawing car (use vehicles camera position info)
            {
				if ( B9_Vehicle( Pawn ) != None )
				{
					camView	= B9_Vehicle( Pawn ).CamPos[ B9_Vehicle( Pawn ).CamPosIndex ];
				}
				else
				if ( B9_KVehicle( Pawn ) != None )
				{
					camView	= B9_KVehicle( Pawn ).CamPos[ B9_KVehicle( Pawn ).CamPosIndex ];
				}

				cameraRotation	= Rotation;



	            View			= camView >> ViewTarget.Rotation;
	            cameraLocation	+= View;
				camLookAt		= cameraLocation;
	            View			= ( vect( 1, 0, 0 ) * camView.W ) >> cameraRotation;
	            cameraLocation	-= View;
				
				if ( Trace( hitLocation, hitNormal, cameraLocation, camLookAt, false ) != None )
				{
					cameraLocation = hitLocation;
				}
            }

			return;
	    }

	    if ( ViewTarget == Self )
	    {
		    cameraRotation	= Rotation;
		    return;
	    }

	    cameraRotation	= ViewTarget.Rotation;

	    if ( bBehindView )
	    {
		    cameraLocation	= cameraLocation + ( ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight ) * vect( 0, 0, 1 );
		    CalcBehindView( cameraLocation, cameraRotation, cameraDist * ViewTarget.Default.CollisionRadius );
	    }
    }

/*
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
	}
*/

/*
    exec function Fire(optional float F)
    {

    }
*/

/*
    exec function AltFire(optional float F)
    {
    }
*/

	function PlayerMove( float DeltaTime )
	{
		local Rotator	vehicleRotation;
		local float		steering;
		local float		throttle;
		local bool		lookSteer;
		local float		lookSteerSens;
		local vector	forward, right, up, lookDir, lookDirInPlane;
		local float		upComp, desYaw;


		if ( B9_Vehicle( Pawn ) != None )
		{
			vehicleRotation	= B9_Vehicle( Pawn ).Rotation;
			lookSteer		= B9_Vehicle( Pawn ).bLookSteer;
			lookSteerSens	= B9_Vehicle( Pawn ).LookSteerSens;
		}
		else
		if ( B9_KVehicle( Pawn ) != None )
		{
			vehicleRotation	= B9_KVehicle( Pawn ).Rotation;
			lookSteer		= B9_KVehicle( Pawn ).bLookSteer;
			lookSteerSens	= B9_KVehicle( Pawn ).LookSteerSens;
		}

        if ( aForward > 1 )
        {
            throttle	= 1;
        }
        else
		if ( aForward < -1 )
        {
            throttle	= -1;
        }
        else
        {
            throttle	= 0;
        }

		// If we are using 'look steer' - take steering from current look vector.
		if ( lookSteer )
		{
			GetAxes( vehicleRotation, forward, right, up);
			lookDir	= vector( Rotation );

			upComp	= lookDir Dot up;

			//If we are looking straight up or down, don't do any steering (go straight) 
			if ( Abs( upComp ) > 0.98f )
			{
				steering	= 0;
			}
			else
			{
				lookDirInPlane	= Normal( lookDir - ( up * upComp ) );

				desYaw	= -65535 / 6.2832 * Acos( FClamp( lookDirInPlane Dot forward, -1.0, 1.0 ) );
				if ( ( lookDirInPlane Dot right ) < 0 )
				{
					desYaw	*= -1;
				}

				steering	= FClamp( desYaw * lookSteerSens, -1.0, 1.0 );
			}
Log("VEHICLE " $ steering );
		}
		// otherwise use the strafe keys for steering.
		// TODO: Add proper follow-cam - but what does mouse do then?
		else 
		{
			if ( aStrafe < -1 )
			{
				steering = 1;
			}
			else
			if ( aStrafe > 1 )
			{
				steering	= -1;
			}
			else
			{
				steering	= 0;
			}
		}

		if ( B9_Vehicle( Pawn ) != None )
		{
			B9_Vehicle( Pawn ).Steering		= steering;
			B9_Vehicle( Pawn ).Throttle		= throttle;
		}
		else
		if ( B9_KVehicle( Pawn ) != None )
		{
			B9_KVehicle( Pawn ).Steering		= steering;
			B9_KVehicle( Pawn ).Throttle		= throttle;
		}

		// update 'looking' rotation - no affect on driving
		UpdateRotation( DeltaTime, 2 );
	}

	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator newRotation, ViewRotation;

		if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
		{
			ViewShake(deltaTime);
			return;
		}
		ViewRotation = Rotation;
		DesiredRotation = ViewRotation; //save old rotation
		if ( bTurnToNearest != 0 )
			TurnTowardNearestEnemy();
		else if ( bTurn180 != 0 )
			TurnAround();
		else
		{
			TurnTarget = None;
			bRotateToDesired = false;
			bSetTurnRot = false;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
		}
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
		{
			If (aLookUp > 0) 
				ViewRotation.Pitch = 18000;
			else
				ViewRotation.Pitch = 49152;
		}

		SetRotation(ViewRotation);

		ViewShake(deltaTime);
		ViewFlash(deltaTime);
			
		NewRotation = ViewRotation;
		NewRotation.Roll = Rotation.Roll;

		// the vehicle will turn itself
		//if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
		//	Pawn.FaceRotation(NewRotation, deltatime);
	}


	function BeginState()
	{
		SetRotation( Pawn.Rotation );
        bBehindView	= true;
//		bFreeCamera	= true;
	}
	
	function EndState()
	{
		if ( B9_AdvancedPawn( Pawn ) != None )
		{
			// "Use" is used to exit, but the anim is not played, so we must explicitly call this
			B9_AdvancedPawn( Pawn ).ActExclusively( false );
		}
	}
}

state PlayerUsingTurret
{

ignores SeePlayer, HearNoise, Bump;

///////////
//
	exec function Use()
	{
		log(" USE!!!" );
		if ( B9_Emplacement( Pawn ) != None )
		{
			B9_Emplacement( Pawn ).Use();
		}
	
		Super.Use();
	}

	exec function CamModeThirdPerson()
	{
		// Don't allow 'true' third person. A very specific
		// camera mode is used instead.
	}
	
	exec function CamModeFirstPerson()
	{
		if( bBehindView )
		{
			bBehindView = false;
		}
	}

///////////
//
	function BeginState()
	{
		// Remember 1st/3rd person camera
		// Then set to 1st so our own mode will work
		//
		bPreservedPersonSetting = bBehindView;
//		CamModeFirstPerson();
	}

	function EndState()
	{
		local B9_Emplacement emplacement;

		emplacement = B9_Emplacement( Pawn );
		if( emplacement != none )
		{
			emplacement.DriverLeave();
		}


		// Restore 1st/3rd person camera
		//
		bBehindView = bPreservedPersonSetting;		

		if ( B9_AdvancedPawn( Pawn ) != None )
		{
			// "Use" is used to exit, but the anim is not played, so we must explicitly call this
			B9_AdvancedPawn( Pawn ).ActExclusively( false );
		}
	}

///////////
//
	exec function Fire(optional float F)
    {
		local B9_Emplacement emplacement;

		emplacement = B9_Emplacement( Pawn );
		if( emplacement != none )
		{
			emplacement.Fire(1);
		}
    }
	
    exec function AltFire(optional float F)
    {
    }

///////////
//
	
	event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		local B9_Emplacement	emplacement;
		local vector			CamOffset, CamPos, X, Y, Z;
		local rotator			temp;

		emplacement = B9_Emplacement( Pawn );
		if( emplacement == none )
		{
			return;
		}

		ViewActor		= emplacement;

		/*
		emplacement.GetAxes( emplacement.Rotation, X, Y, Z );
		CamOffset		= emplacement.fCameraOffset;
		CamPos			= emplacement.Location + (X*CamOffset.X) + (Y*CamOffset.Y) + (Z*CamOffset.Z);
		CameraLocation	= CamPos;
		*/

		emplacement.GetCameraPosition( CamPos );
		CameraLocation	= CamPos;

	
		//log( ""$CameraRotation.Pitch$" "$CameraRotation.Yaw$" "$CameraRotation.Roll );
		
		//CameraRotation = Rotation;

//		temp.Pitch=0;
//		temp.Yaw+=16535;
//		temp.Roll=0;
	//	CameraRotation	+= temp;
	}
		
	
	function PlayerMove( float DeltaTime )
	{
		local B9_Emplacement emplacement;
		
		/*
		// check for 'jump' to throw the driver out.
        //
		if( bPressedJump )
        {
            GotoState('PlayerWalking');
            return;
        }
		*/

		
		emplacement = B9_Emplacement( Pawn );
		if( emplacement == none )
		{
			return;
		}

		UpdateRotation( DeltaTime, 2 );
		//emplacement.OrientGun( Rotation );
	}

	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator newRotation, ViewRotation;
		local B9_Emplacement emplacement;

		emplacement = B9_Emplacement( Pawn );
		if( emplacement == none )
		{
			return;
		}
		
		ViewRotation	= Rotation;
		DesiredRotation = ViewRotation; //save old rotation
		
		TurnTarget			= None;
		bRotateToDesired	= false;
		bSetTurnRot			= false;
		ViewRotation.Yaw	+= (32.0 * DeltaTime * aTurn )   * 0.2;
		ViewRotation.Pitch	+= (32.0 * DeltaTime * aLookUp ) * 0.2;
		
		
		// Fix pitch extent
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
		{
			if (aLookUp > 0) 
			{
				ViewRotation.Pitch = 18000;
			}
			else
			{
				ViewRotation.Pitch = 49152;
			}
		}
		
		SetRotation(ViewRotation);
		emplacement.OrientGun( ViewRotation );
		Pawn.FaceRotation(ViewRotation, deltatime);
//		
//		NewRotation			= ViewRotation;
//		NewRotation.Roll	= Rotation.Roll;
		
		

		/*
		if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
			Pawn.FaceRotation(NewRotation, deltatime);
			*/

			
	}
	

/*
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
	}
*/
}

//////////////////////////////////
// Special state used for temporarily trapping
// player movement inputs. Useful for things like
// getting up after a long fall.
//
simulated state SuspendPlayerInput
{
	exec function ForceReload() {}
	exec function Jump( optional float F ) {}
	exec function ActivateInventoryItem( class InvItem ) {}
	exec function ThrowWeapon() {}
	exec function PrevWeapon() {}
	exec function NextWeapon() {}
	exec function SwitchWeapon (byte F ) {}
	exec function PrevItem() {}
	exec function ActivateItem() {}
	exec function Fire( optional float F ) {}
	exec function AltFire( optional float F ) {}
	exec function Use() {}
	exec function InventoryUp() {}
	exec function InventoryDown() {}
	exec function InventoryLeft() {}
	exec function InventoryRight() {}
	exec function InventoryDrop() {}
	exec function ActivateSkill() {}
	exec function PutDownGun() {}

	function PlayerMove( float DeltaTime )
	{
		UpdateRotation( DeltaTime, 1 );
	}

}

exec function AssassinGesture1()
{
	CurrentGesture = 1;
	GotoState( 'Idling' );
}

exec function AssassinGesture2()
{
	CurrentGesture = 2;
	GotoState( 'Idling' );
}

exec function AssassinGesture3()
{
	CurrentGesture = 3;
	GotoState( 'Idling' );
}

exec function AssassinGesture4()
{
	CurrentGesture = 4;
	GotoState( 'Idling' );
}

state Idling
{
	function PlayerMove( float DeltaTime )
	{
		local vector X, Y, Z, NewAccel;
		local rotator ViewRotation;

		/*
		if ( Pawn.Weapon != None )
		{
			BuildTargetList( B9_HUD( MyHud ).fTargets );
		}
		*/

		// Update camera position
		fCamera.SetTurn( aTurn * 32, DeltaTime );
		fCamera.SetPitch( aLookUp * 32, DeltaTime );

		// Update acceleration
		GetAxes( fCamera.Rotation, X, Y, Z );

		// Use the camera's Y axis to direct character because it is almost always horizontal (parallel to the X,Y plane)
		// Rotate Y axis 90 degrees to get the X axis, Z is not used
		X.x = Y.y;
		X.y = -Y.x;
		X.z = 0;
		NewAccel = fAwayFromCamera * X + fWithCamera * Y;
		NewAccel.Z = 0;

		if ( VSize(NewAccel) > 0 || bPressedJump )
		{
			GotoState( 'PlayerWalking' );
		}

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, rot(0,0,0) );
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, rot(0,0,0) );
		
		bPressedJump = false;
	}

Begin:
	//B9_PlayerPawn(Pawn).PlayGesture(CurrentGesture, 0.3);
	B9_PlayerPawn(Pawn).PlayGesture( CurrentGesture, 1.0 );
	FinishAnim();
	GotoState( 'PlayerWalking' );
}

state Dead
{
	exec function ForceReload() {E3_BackToMainMenu();}
	exec function Jump( optional float F ) {E3_BackToMainMenu();}
	exec function ActivateInventoryItem( class InvItem ) {E3_BackToMainMenu();}
	exec function ThrowWeapon() {E3_BackToMainMenu();}
	exec function PrevWeapon() {E3_BackToMainMenu();}
	exec function NextWeapon() {E3_BackToMainMenu();}
	exec function SwitchWeapon (byte F ) {E3_BackToMainMenu();}
	exec function PrevItem() {E3_BackToMainMenu();}
	exec function ActivateItem() {E3_BackToMainMenu();}
	exec function Fire( optional float F ) {E3_BackToMainMenu();}
	exec function AltFire( optional float F ) {E3_BackToMainMenu();}
	exec function Use() {E3_BackToMainMenu();}
	exec function InventoryUp() {E3_BackToMainMenu();}
	exec function InventoryDown() {E3_BackToMainMenu();}
	exec function InventoryLeft() {E3_BackToMainMenu();}
	exec function InventoryRight() {E3_BackToMainMenu();}
	exec function InventoryDrop() {E3_BackToMainMenu();}
	exec function ActivateSkill() {E3_BackToMainMenu();}
	exec function PutDownGun() {E3_BackToMainMenu();}

	function E3_BackToMainMenu()
	{
		if( Level.Netmode==NM_Standalone )
			ClientTravel( "b9menu_main", TRAVEL_Absolute, false );
	}
}

simulated  function Interaction ShowKeyInput(class<B9_MenuInteraction> MenuClass)
{
	local Interaction mm;

	if (Factory == None)
		Factory = new(None) FactoryClass;

	if (!Factory.IsInteractionActive(MenuClass, self, self.Player))
	{
		mm = Factory.PushInteraction(MenuClass, self, self.Player);
		return mm;
	}
}

// The following functions are needed to support HQ operations.

simulated function ShowStandardKiosk(class<B9_MenuInteraction> MenuClass, rotator TriggerRot)
{
	local Interaction mm;

	if (Factory == None)
		Factory = new(None) FactoryClass;
	if (!Factory.IsInteractionActive(MenuClass, self, self.Player))
	{
		Log("B9_HQListener asked to activate kiosk " $ MenuClass );
		mm = Factory.PushInteraction(MenuClass, self, self.Player);
		B9_MenuInteraction(mm).SetGenericRotator(0, TriggerRot);
	}
}

simulated function ShowNanoCalKiosk(class<B9_MenuInteraction> MenuClass, rotator TriggerRot, B9_Skill skill)
{
	local Interaction mm;

	if (Factory == None)
		Factory = new(None) FactoryClass;
	if (!Factory.IsInteractionActive(MenuClass, self, self.Player))
	{
		Log("B9_HQListener asked to activate kiosk " $ MenuClass );			
		mm = Factory.PushInteraction(MenuClass, self, self.Player);
		B9_MenuInteraction(mm).SetGenericRotator(0, TriggerRot);
		B9_MenuInteraction(mm).SetGenericObject(0, skill);
	}
}

simulated function ShowIntrinsicSkillDisplay(class<B9_MenuInteraction> MenuClass, rotator TriggerRot, string skillName)
{
	local Interaction mm;

	if (Factory == None)
		Factory = new(None) FactoryClass;
	if (!Factory.IsInteractionActive(MenuClass, self, self.Player))
	{
		Log("B9_HQListener asked to activate kiosk " $ MenuClass );
		mm = Factory.PushInteraction(MenuClass, self, self.Player);
		B9_MenuInteraction(mm).SetGenericRotator(0, TriggerRot);
		B9_MenuInteraction(mm).SetGenericString(0, skillName);
	}
}

simulated function ShowMissionKitKiosk(class<B9_MenuInteraction> MenuClass, rotator TriggerRot, string tagName)
{
	local Interaction mm;

	if (Factory == None)
		Factory = new(None) FactoryClass;
	if (!Factory.IsInteractionActive(MenuClass, self, self.Player))
	{
		Log("B9_HQListener asked to activate kiosk " $ MenuClass );
		mm = Factory.PushInteraction(MenuClass, self, self.Player);
		B9_MenuInteraction(mm).SetGenericString(0, tagName);
	}
}

function TriggerSideEffects(string ttn)
{
	local Triggers T;
	local string tn;

	ForEach AllActors(class'Triggers', T)
	{
		tn = "" $ T.Tag;
		if (tn == ttn)
			T.Trigger(fHQListener, Pawn);
	}
}

function bool CanEnterKiosk(Triggers TriggerSource, out int showError)
{
	local B9_PlayerPawn OtherPawn;
	local B9_PlayerController OtherController;

	if (fKioskTrigger != None)
	{
		if (fKioskTrigger != TriggerSource)
			showError = 1;

		return false;
	}

	/* Disabling kiosk exclusion code.

	// This code prevents two players from activating the same kiosk.
	// This may not be rule though.
	ForEach AllActors(class'B9_PlayerPawn', OtherPawn)
	{
		if (OtherPawn != Pawn)
		{
			OtherController = B9_PlayerController(OtherPawn.Controller);
			if (OtherController.fKioskTrigger == TriggerSource)
			{
				showError = 1;
				return false;
			}
		}
	}
	*/

	return true;
}

simulated function SetKioskView(rotator NewRot, float NewFOV)
{
	if (ROLE != ROLE_Authority)
	{
		SetRotation(NewRot);
		Pawn.SetRotation(NewRot);

		if (NewFOV != 0.0f)
			SetFOV(NewFOV);
	}
}

function bool EnterKioskMode(Actor Listener, Triggers TriggerSource, string TriggerTagName,
							 float kioskBackOff, float kioskFOV, out int showError)
{
	local vector loc, ploc, X, Y, Z;
	local rotator rot;

	if (!CanEnterKiosk(TriggerSource, showError))
		return false;

	fHQListener = Listener;
	fKioskTrigger = TriggerSource;

	TriggerSideEffects(TriggerTagName);
	fKioskTriggerTagName = TriggerTagName;

	bOldBehindView = bBehindView;
	BehindView(false);

	//fOldWeapon = Pawn.Weapon;
	//if (fOldWeapon != None)
	//	PutDownGun();

	rot = TriggerSource.Rotation;

	SetRotation(rot);
	Pawn.SetRotation(rot);

	if (kioskFOV != 0.0f)
		SetFOV(kioskFOV);
	fKioskFOV = kioskFOV;

	SetKioskView(rot, kioskFOV); // replicated call needed for MP

/*
	loc = TriggerSource.Location;
	ploc = Pawn.Location;
	ploc.X = loc.X;
	ploc.Y = loc.Y;

	if (kioskBackOff != 0.0f)
	{
		GetAxes(rot, X, Y, Z);
		ploc -= kioskBackOff * X;
	}

	SetLocation(ploc);
	Pawn.SetLocation(ploc);
*/
	
	return true;
}

simulated function ResetKioskView()
{
	if (ROLE != ROLE_Authority)
	{
		ResetFOV();
	}
}

function ExitKioskMode()
{
	local vector loc;

	TriggerSideEffects(fKioskTriggerTagName);

	if (fKioskFOV != 0.0f)
	{
		ResetFOV();
		ResetKioskView(); // replicated call needed for MP
	}
	BehindView(bOldBehindView);

	//if (fOldWeapon != None)
	//{
	//	Pawn.PendingWeapon = fOldWeapon;
	//	Pawn.ChangedWeapon();
	//	fOldWeapon.BringUp();
	//}

	// try to extract character from kiosk (remove this when collision hulls simplified)
	loc = Pawn.Location;
	loc.Z += 20;
	Pawn.SetLocation(loc);

	fKioskTriggerTagName = ""; // clear it
	fKioskTrigger = None;
}

simulated function ShowLocationMessage(string msg)
{
	local B9_HUD hud;

	hud = B9_HUD(MyHud);
	if (hud != None) hud.ShowLocationMessage(msg);
}

simulated function ShowInteraction(class<B9_MenuInteraction> InteractionClass, vector L, string M)
{
	local Interaction mm;

	if (Factory == None)
		Factory = new(None) FactoryClass;
	if (!Factory.IsInteractionActive(InteractionClass, self, self.Player))
	{
		mm = Factory.PushInteraction(InteractionClass, self, self.Player);
		B9_MenuInteraction(mm).SetGenericString(0, M);
		B9_MenuInteraction(mm).SetGenericVector(0, L);
	}
}


//////////////
//

exec function TestNV()
{
	if( !bNVTestOn )
	{
		bNVTestOn = true;
		SetNewVisionMode( VM_NightScope );
	}
	else
	{
		if( fVisionMode == VM_NightScope )
		{
			bNVTestOn = false;
			SetNewVisionMode( VM_Normal );
		}
		else
		{
			SetNewVisionMode( VM_NightScope );
		}
	}
}

exec function TestHERA()
{
	if( !bNVTestOn )
	{
		bNVTestOn = true;
		//CreateCameraEffect( class'VisionFX_HERA_Engage' );
		SetNewVisionMode( VM_HERA );
	}
	else
	{
		//CreateCameraEffect( class'VisionFX_HERA_Engage' );
		if( fVisionMode == VM_HERA )
		{
			bNVTestOn = false;
			SetNewVisionMode( VM_Normal );
		}
		else
		{
            SetNewVisionMode( VM_HERA );
		}
	}
}

function SetNewVisionMode( EVisionMode mode )
{
	local B9_HUD hud;
	hud = B9_HUD(MyHud);

	if( fVisionMode != VM_Normal )
	{
		TurnOffOldVisionMode();
	}

	fVisionMode = mode;
	SetVisionMode( fVisionMode );

	if( fVisionMode == VM_NightScope || fVisionMode == VM_HERA )
	{
		hud.DrawNightscopeOverlay( true );
	}
	else
	{
		hud.DrawNightscopeOverlay( false );
	}
}

function TurnOffOldVisionMode()
{
	local Inventory Inv;
	local B9_Skill	skill;


	for( Inv = B9_PlayerPawn(Pawn).Inventory; Inv != None; Inv = Inv.Inventory )
	{
		skill = B9_Skill( Inv );
		if( skill != None && skill.IsVisionMode() && skill.fActive )
		{
			skill.Deactivate(); // toggle off without causing a vision mode switch to VM_Normal
		}
	}
}

function ChangeTeam( int N )
{
	local TeamInfo OldTeam;
	UpdateURL("Team",string(N), true);	
	OldTeam = PlayerReplicationInfo.Team;
	Level.Game.ChangeTeam(self, N, true);
	if( Level.Game.IsA('B9_MultiPlayerHQGameInfo') == false)
	{
		if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
			Pawn.Died( None, class'DamageType', Pawn.Location );
	}
}

function TeamChanged()
{
	if (PlayerReplicationInfo.Team == None)
		fSkinIndexCopy = 0;
	else
		fSkinIndexCopy = PlayerReplicationInfo.Team.TeamIndex + 1;

	Log("Team="$PlayerReplicationInfo.Team$" skinNum="$fSkinIndexCopy$" Pawn="$Pawn);
	if (B9_PlayerPawn(Pawn) != None)
		B9_PlayerPawn(Pawn).SetSkinIndex(fSkinIndexCopy);
}

function GivePawn(Pawn NewPawn)
{
	Super.GivePawn(NewPawn);
	if (Pawn == NewPawn && Pawn != None)
		Pawn.SetSkinIndex(fSkinIndexCopy);
}

function Restart()
{
	Super.Restart();
	if (Pawn != None)
		Pawn.SetSkinIndex(fSkinIndexCopy);
}

//////////// Joe's test code

function ServerJoeTest()
{
	if (++fSkinIndexCopy == 4)
		fSkinIndexCopy = 0;
	B9_PlayerPawn(Pawn).SetSkinIndex(fSkinIndexCopy);
}

exec function JoeTest()
{
	// B9_PlayerPawn(Pawn).SetHelmet();

	ServerJoeTest();
}

//////////////

defaultproperties
{
	bLockTargetDesired=true
	FactoryClass=Class'B9BasicTypes.B9_MenuInteraction'
	fPDAClass=Class'B9BasicTypes.B9_PDABase'
	SniperZoomOut=Sound'B9Weapons_sounds.HeavyWeapons.sniper_zoom_out'
	SniperZoomIn=Sound'B9Weapons_sounds.HeavyWeapons.sniper_zoom_in'
	bBehindView=true
	CameraDist=10
	fCloakFXClass=Class'B9FX.fx_CloakSparkle'
}