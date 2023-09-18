class B9_PDA_Cheats_Summon extends B9_MenuPDA_Menu;

var localized string fSummonMagnumLabel;
var localized string fSummonShotgunLabel;
var localized string fSummonAssaultRifleLabel;
var localized string fSummonFlamethrowerLabel;
var localized string fSummonHandToHandLabel;
var localized string fSummonSniperRifleLabel;
var localized string fSummonGrenadeLaunherLabel;
var localized string fSummonHeavyMachineGunLabel;
var localized string fSummonRailGunLabel;
var localized string fSummonRocketLauncherLabel;
var localized string fSummonRadFluxLabel;
var localized string fSummonMarineAssaultLabel;
var localized string fSummonDoubleBarrelLabel;
var localized string fSummon9mmLabel;
var localized string fSummonSilencedPistolLabel;
var localized string fSummonPistolTazerLabel;
var localized string fSummonSMGLabel;
var localized string fSummonSawedOffLabel;
var localized string fSummonCrossBowLabel;
var localized string fSummonGrapplingHookLabel;
var localized string fSummonPressureMineLabel;
var localized string fSummonProxyMineLabel;
var localized string fSummonTripMineLabel;
var localized string fSummonkatanaLabel;
var localized string fSummondaggerLabel;
var localized string fSummonblackjackLabel;
var localized string fSummonTazerLabel;
var localized string fSummonBlitSwordLabel;
var localized string fSummonBlitDaggerLabel;
var localized string fSummonB9_TossedGrenadeLabel;
var localized string fSummonB9_TossedCanLabel;
var localized string fSummonExplosive_Gren_FragLabel;
var localized string fSummonExplosive_Gren_FlashbangLabel;
var localized string fSummonB9_HandGrenadeLabel;
var localized string fSummonExplosive_Gren_MIRVLabel;
var localized string fSummonExplosive_Gren_FlareLabel;
var localized string fSummonExplosive_SatchelChargeLabel;
var localized string fSummonExplosive_DetPackLabel;

var bool fGhostModeOn;
var bool fFlyModeOn;

// Event IDs
const kEvent_SummonMagnum = 0;
const kEvent_SummonShotgun = 1;
const kEvent_SummonAssaultRifle = 2;
const kEvent_SummonFlamethrower = 3;
const kEvent_SummonHandToHand = 4;
const kEvent_SummonSniperRifle = 5;
const kEvent_SummonGrenadeLaunher = 6;	
const kEvent_SummonHeavyMachineGun = 7;	
const kEvent_SummonRailGun = 8;			
const kEvent_SummonRocketLauncher = 9;	
const kEvent_SummonRadFlux = 10;		
const kEvent_SummonMarineAssault = 11;	
const kEvent_SummonDoubleBarrel = 12;	
const kEvent_fSummon9mm = 13;			
const kEvent_fSummonSilencedPistol = 14;
const kEvent_fSummonPistolTazer = 15;			
const kEvent_fSummonSMG = 16;			
const kEvent_fSummonSawedOff = 17;		
const kEvent_fSummonCrossBow = 18;		
const kEvent_fSummonGrapplingHook = 19;	
const kEvent_SummonPressureMine = 20;
const kEvent_SummonProxyMine = 21;
const kEvent_SummonTripMine = 22;
const kEvent_SummonkatanaLabel = 23;
const kEvent_SummondaggerLabel = 24;
const kEvent_SummonblackjackLabel = 25;
const kEvent_SummonTazerLabel = 26;
const kEvent_SummonBlitSwordLabel = 27;
const kEvent_SummonBlitDaggerLabel = 28;
const kEvent_SummonB9_TossedGrenadeLabel = 29;
const kEvent_SummonB9_TossedCanLabel = 30;
const kEvent_SummonExplosive_Gren_FragLabel = 31;
const kEvent_SummonExplosive_Gren_FlashbangLabel = 32;
const kEvent_SummonB9_HandGrenadeLabel = 33;
const kEvent_SummonExplosive_Gren_MIRVLabel = 34;
const kEvent_SummonExplosive_Gren_FlareLabel = 35;
const kEvent_SummonExplosive_SatchelChargeLabel = 36;
const kEvent_SummonExplosive_DetPackLabel = 37;



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
	local displayItem newItem;
	log("DO we have a RootController?"$fPDABase.RootController);
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonMagnumLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonMagnum;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonShotgunLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonShotgun;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonAssaultRifleLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonAssaultRifle;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonFlamethrowerLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonFlamethrower;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonHandToHandLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonHandToHand;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonSniperRifleLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonSniperRifle;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonGrenadeLaunherLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonGrenadeLaunher;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonHeavyMachineGunLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonHeavyMachineGun;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonRailGunLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonRailGun;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonRocketLauncherLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonRocketLauncher;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonRadFluxLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonRadFlux;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonMarineAssaultLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonMarineAssault;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonDoubleBarrelLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonDoubleBarrel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummon9mmLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_fSummon9mm;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonSilencedPistolLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_fSummonSilencedPistol;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonPistolTazerLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_fSummonPistolTazer;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonSMGLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_fSummonSMG;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonSawedOffLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_fSummonSawedOff;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonCrossBowLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_fSummonCrossBow;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonGrapplingHookLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_fSummonGrapplingHook;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonPressureMineLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonPressureMine;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonProxyMineLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonProxyMine;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonTripMineLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonTripMine;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonkatanaLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonkatanaLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummondaggerLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummondaggerLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonblackjackLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonblackjackLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonTazerLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonTazerLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonBlitSwordLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonBlitSwordLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonBlitDaggerLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonBlitDaggerLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonB9_TossedGrenadeLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonB9_TossedGrenadeLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonB9_TossedCanLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonB9_TossedCanLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonExplosive_Gren_FragLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonExplosive_Gren_FragLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonExplosive_Gren_FlashbangLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonExplosive_Gren_FlashbangLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonB9_HandGrenadeLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonB9_HandGrenadeLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonExplosive_Gren_MIRVLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonExplosive_Gren_MIRVLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonExplosive_Gren_FlareLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonExplosive_Gren_FlareLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonExplosive_SatchelChargeLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonExplosive_SatchelChargeLabel;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fSummonExplosive_DetPackLabel;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_SummonExplosive_DetPackLabel;
	AddDisplayItem( newItem );
}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		case kEvent_SummonMagnum:
			Summon( "pistol_Magnum", "ammo_MagnumBullet_Pickup" );
		break;
		
		case kEvent_SummonShotgun:
			Summon( "rifle_Shotgun", "ammo_ShotgunShell_Pickup" );
		break;
		
		case kEvent_SummonAssaultRifle:
			Summon( "rifle_Assault", "ammo_AssaultRifle_Pickup" );
		break;
		
		case kEvent_SummonFlamethrower:
			Summon( "heavy_FlameThrower", "ammo_FlameThrower_Pickup" );
		break;
		
		case kEvent_SummonHandToHand:
			Summon( "HandToHand" );
		break;

		case kEvent_SummonSniperRifle:
			Summon( "rifle_sniper", "ammo_SniperRifle_Pickup" );
		break;


		case kEvent_SummonGrenadeLaunher:
			Summon( "heavy_GrenadeLauncher", "ammo_LaunchedGrenade_Pickup" );
		break;

		case kEvent_SummonHeavyMachineGun:
			Summon( "heavy_HeavyMachineGun", "ammo_HMGBullets_Pickup" );
		break;

		case kEvent_SummonRailGun:
			Summon( "heavy_RailGun", "ammo_RailGun" );
		break;

		case kEvent_SummonRocketLauncher:
			Summon( "heavy_RocketLauncher", "ammo_HeavyRocket_Pickup" );
		break;

		case kEvent_SummonRadFlux:
			Summon( "heavy_RadFlux", "ammo_RadFlux_Pickup" );
		break;

		case kEvent_SummonMarineAssault:
			Summon( "rifle_MarineAssault", "ammo_AssaultRifle_Pickup" );
		break;

		case kEvent_SummonDoubleBarrel:
			Summon( "rifle_DB_Shotgun", "ammo_ShotgunShell_Pickup" );
		break;

		case kEvent_fSummon9mm:
			Summon( "pistol_9mm", "ammo_9mmBullet_Pickup" );
		break;

		case kEvent_fSummonSilencedPistol:
			Summon( "pistol_Silenced", "ammo_SilencedPistol_Pickup" );
		break;

		case kEvent_fSummonPistolTazer:
			Summon( "pistol_Tazer", "ammo_Tazer_Pickup" );
		break;

		case kEvent_fSummonSMG:
			Summon( "pistol_SMG", "ammo_SMG_Pickup" );
		break;

		case kEvent_fSummonSawedOff:
			Summon( "pistol_SawedOffShotgun", "ammo_ShotgunShell_Pickup" );
		break;

		case kEvent_fSummonCrossBow:
			Summon( "Crossbow", "ammo_CrossbowBolt_Pickup" );
		break;

		case kEvent_fSummonGrapplingHook:
			Summon( "GrapplingHook", "GrapplingHookAmmunition_Pickup" );
		break;

		case kEvent_SummonPressureMine:
			Summon( "Explosive_Mine_Pressure" );
		break;
	
		case kEvent_SummonProxyMine:
			Summon( "Explosive_Mine_Proximity" );
		break;

		case kEvent_SummonTripMine:
			Summon( "Explosive_Mine_Trip" );
		break;

		case kEvent_SummonkatanaLabel:
			Summon( "katana" );
		break;

		case kEvent_SummondaggerLabel:
			Summon( "dagger" );
		break;

		case kEvent_SummonblackjackLabel:
			Summon( "blackjack" );
		break;

		case kEvent_SummonTazerLabel:
			Summon( "Tazer" );
		break;

		case kEvent_SummonBlitSwordLabel:
			Summon( "BlitSword" );
		break;

		case kEvent_SummonBlitDaggerLabel:
			Summon( "BlitDagger" );
		break;

		case kEvent_SummonB9_TossedGrenadeLabel:
			Summon( "B9_TossedGrenade" );
		break;

		case kEvent_SummonB9_TossedCanLabel:
			Summon( "B9_TossedCan" );
		break;

		case kEvent_SummonExplosive_Gren_FragLabel:
			Summon( "Explosive_Gren_Frag" );
		break;

		case kEvent_SummonExplosive_Gren_FlashbangLabel:
			Summon( "Explosive_Gren_Flashbang" );
		break;

		case kEvent_SummonB9_HandGrenadeLabel:
			Summon( "B9_HandGrenade" );
		break;

		case kEvent_SummonExplosive_Gren_MIRVLabel:
			Summon( "Explosive_Gren_MIRV" );
		break;

		case kEvent_SummonExplosive_Gren_FlareLabel:
			Summon( "Explosive_Gren_Flare" );
		break;

		case kEvent_SummonExplosive_SatchelChargeLabel:
			Summon( "Explosive_SatchelCharge" );
		break;

		case kEvent_SummonExplosive_DetPackLabel:
			Summon( "Explosive_DetPack" );
		break;
	}
}

function Summon( String weapon, optional String ammo )
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "AcquireInventory " $ "B9Weapons." $ weapon  );
	if( ammo != "" )
		fPDABase.RootController.ConsoleCommand( "AcquireInventory " $ "B9Weapons." $ ammo  );
}


function Initialize()
{
	//Don't do anything requiring controllers here!
}
defaultproperties
{
	fSummonMagnumLabel=" Magnum "
	fSummonShotgunLabel=" Shotgun "
	fSummonAssaultRifleLabel=" Assault Rifle "
	fSummonFlamethrowerLabel=" Flamethrower "
	fSummonHandToHandLabel=" Hand to Hand "
	fSummonSniperRifleLabel=" Sniper Rifle "
	fSummonGrenadeLaunherLabel=" Grenade Launcer "
	fSummonHeavyMachineGunLabel=" Hvy Machine Gun "
	fSummonRailGunLabel=" Rail Gun "
	fSummonRocketLauncherLabel=" Rocket Launcher "
	fSummonRadFluxLabel=" Rad Flux "
	fSummonMarineAssaultLabel=" Marine Assault "
	fSummonDoubleBarrelLabel=" Double Barrel "
	fSummon9mmLabel=" 9 mm "
	fSummonSilencedPistolLabel=" Silenced Pistol "
	fSummonPistolTazerLabel=" Pistol Tazer "
	fSummonSMGLabel=" SMG "
	fSummonSawedOffLabel=" Sawed Off "
	fSummonCrossBowLabel=" Cross bow "
	fSummonGrapplingHookLabel=" Grappling Hook "
	fSummonPressureMineLabel=" Pressure Mine "
	fSummonProxyMineLabel=" Proximity Mine "
	fSummonTripMineLabel=" Trip Mine "
	fSummonkatanaLabel=" Katana "
	fSummondaggerLabel=" Dagger "
	fSummonblackjackLabel=" Black Jack "
	fSummonTazerLabel=" Tazer "
	fSummonBlitSwordLabel=" Blit Sword "
	fSummonBlitDaggerLabel=" Blit Dagger "
	fSummonB9_TossedGrenadeLabel=" Tossed Grenade "
	fSummonB9_TossedCanLabel="Can Grenade "
	fSummonExplosive_Gren_FragLabel=" Frag Grenade "
	fSummonExplosive_Gren_FlashbangLabel="Flash Bang "
	fSummonB9_HandGrenadeLabel="Hand Grenade "
	fSummonExplosive_Gren_MIRVLabel=" MIRV Grenade "
	fSummonExplosive_Gren_FlareLabel="Flare Grenade "
	fSummonExplosive_SatchelChargeLabel="Satchel Charge "
	fSummonExplosive_DetPackLabel=" Det Pack "
}