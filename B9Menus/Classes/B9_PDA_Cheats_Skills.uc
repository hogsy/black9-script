class B9_PDA_Cheats_Skills extends B9_MenuPDA_Menu;

var localized string fAquireBaseAttackSkill_Label;
var localized string fAquireDummyMod_Label;
var localized string fAquireDummySkill_Label;
var localized string fAquireskill_BlinkSpeed_Label;
var localized string fAquireskill_CamJam_Label;
var localized string fAquireskill_Defocus_Label;
var localized string fAquireskill_ECM_Label;
var localized string fAquireskill_FireArmsTargeting_Label;
var localized string fAquireskill_Fireball_Label;
var localized string fAquireskill_Fireball_Projectile_Label;
var localized string fAquireskill_FireFist_Label;
var localized string fAquireskill_FireShield_Label;
var localized string fAquireskill_Hacking_Label;
var localized string fAquireskill_Healing_Label;
var localized string fAquireskill_HeavenBlast_Label;
var localized string fAquireskill_HeavyWeaponsTargeting_Label;
var localized string fAquireskill_HydroCloak_Label;
var localized string fAquireskill_HydroShock_Label;
var localized string fAquireskill_IceFist_Label;
var localized string fAquireskill_IceShards_Label;
var localized string fAquireskill_Jumping_Label;
var localized string fAquireskill_meleeCombat_Label;
var localized string fAquireskill_OpticCloak_Label;
var localized string fAquireskill_RockFist_Label;
var localized string fAquireskill_RockGrenade_Label;
var localized string fAquireskill_RockShards_Label;
var localized string fAquireskill_urbanTracking_Label;


// Event IDs
const kEvent_AquireBaseAttackSkill = 0;
const kEvent_AquireDummyMod = 1;
const kEvent_AquireDummySkill = 2;
const kEvent_Aquireskill_BlinkSpeed = 3;
const kEvent_Aquireskill_CamJam = 4;
const kEvent_Aquireskill_Defocus = 5;
const kEvent_Aquireskill_ECM = 6;
const kEvent_Aquireskill_FireArmsTargeting = 7;
const kEvent_Aquireskill_Fireball = 8;
const kEvent_Aquireskill_Fireball_Projectile = 9;
const kEvent_Aquireskill_FireFist = 10;
const kEvent_Aquireskill_FireShield = 11;
const kEvent_Aquireskill_Hacking = 12;
const kEvent_Aquireskill_Healing = 13;
const kEvent_Aquireskill_HeavenBlast = 14;
const kEvent_Aquireskill_HeavyWeaponsTargeting = 15;
const kEvent_Aquireskill_HydroCloak = 16;
const kEvent_Aquireskill_HydroShock = 17;
const kEvent_Aquireskill_IceFist = 18;
const kEvent_Aquireskill_IceShards = 19;
const kEvent_Aquireskill_Jumping = 20;
const kEvent_Aquireskill_meleeCombat = 21;
const kEvent_Aquireskill_OpticCloak = 22;
const kEvent_Aquireskill_RockFist = 23;
const kEvent_Aquireskill_RockGrenade = 24;
const kEvent_Aquireskill_RockShards = 25;
const kEvent_Aquireskill_urbanTracking = 26;



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
	newItem.fLabel = fAquireBaseAttackSkill_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_AquireBaseAttackSkill;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireDummyMod_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_AquireDummyMod;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireDummySkill_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_AquireDummySkill;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_BlinkSpeed_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_BlinkSpeed;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_CamJam_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_CamJam;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_Defocus_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_Defocus;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_ECM_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_ECM;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_FireArmsTargeting_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_FireArmsTargeting;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_Fireball_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_Fireball;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_Fireball_Projectile_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_Fireball_Projectile;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_FireFist_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_FireFist;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_FireShield_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_FireShield;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_Hacking_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_Hacking;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_Healing_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_Healing;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_HeavenBlast_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_HeavenBlast;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_HeavyWeaponsTargeting_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_HeavyWeaponsTargeting;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_HydroCloak_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_HydroCloak;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_HydroShock_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_HydroShock;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_IceFist_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_IceFist;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_IceShards_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_IceShards;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_Jumping_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_Jumping;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_meleeCombat_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_meleeCombat;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_OpticCloak_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_OpticCloak;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_RockFist_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_RockFist;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_RockGrenade_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_RockGrenade;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_RockShards_Label;
	newItem.fDrawNextItemTotheRight=true;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_RockShards;
	AddDisplayItem( newItem );

	newItem = new(None)class'displayItem';
	newItem.fLabel = fAquireskill_urbanTracking_Label;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Aquireskill_urbanTracking;
	AddDisplayItem( newItem );
}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		case kEvent_AquireBaseAttackSkill:
			Aquire( "BaseAttackSkill" );
		break;
		
		case kEvent_AquireDummyMod:
			Aquire( "DummyMod" );
		break;

		case kEvent_AquireDummySkill:
			Aquire( "DummySkill" );
		break;

		case kEvent_Aquireskill_BlinkSpeed:
			Aquire( "skill_BlinkSpeed" );
		break;

		case kEvent_Aquireskill_CamJam:
			Aquire( "skill_CamJam" );
		break;

		case kEvent_Aquireskill_Defocus:
			Aquire( "skill_Defocus" );
		break;

		case kEvent_Aquireskill_ECM:
			Aquire( "skill_ECM" );
		break;

		case kEvent_Aquireskill_FireArmsTargeting:
			Aquire( "skill_FireArmsTargeting" );
		break;

		case kEvent_Aquireskill_Fireball:
			Aquire( "skill_Fireball" );
		break;

		case kEvent_Aquireskill_Fireball_Projectile:
			Aquire( "skill_Fireball_Projectile" );
		break;

		case kEvent_Aquireskill_FireFist:
			Aquire( "skill_FireFist" );
		break;

		case kEvent_Aquireskill_FireShield:
			Aquire( "skill_FireShield" );
		break;

		case kEvent_Aquireskill_Hacking:
			Aquire( "skill_Hacking" );
		break;

		case kEvent_Aquireskill_Healing:
			Aquire( "skill_Healing" );
		break;

		case kEvent_Aquireskill_HeavenBlast:
			Aquire( "skill_HeavenBlast" );
		break;

		case kEvent_Aquireskill_HeavyWeaponsTargeting:
			Aquire( "skill_HeavyWeaponsTargeting" );
		break;

		case kEvent_Aquireskill_HydroCloak:
			Aquire( "skill_HydroCloak" );
		break;

		case kEvent_Aquireskill_HydroShock:
			Aquire( "skill_HydroShock" );
		break;
//
		case kEvent_Aquireskill_IceFist:
			Aquire( "skill_IceFist" );
		break;

		case kEvent_Aquireskill_IceShards:
			Aquire( "skill_IceShards" );
		break;

		case kEvent_Aquireskill_Jumping:
			Aquire( "skill_Jumping" );
		break;

		case kEvent_Aquireskill_meleeCombat:
			Aquire( "skill_meleeCombat" );
		break;

		case kEvent_Aquireskill_OpticCloak:
			Aquire( "skill_OpticCloak" );
		break;

		case kEvent_Aquireskill_RockFist:
			Aquire( "skill_RockFist" );
		break;

		case kEvent_Aquireskill_RockGrenade:
			Aquire( "skill_RockGrenade" );
		break;

		case kEvent_Aquireskill_RockShards:
			Aquire( "skill_RockShards" );
		break;

		case kEvent_Aquireskill_urbanTracking:
			Aquire( "skill_urbanTracking" );
		break;
	}
}

function Aquire( String skill )
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "AcquireInventory " $ "B9NanoSkills." $ skill  );
}


function Initialize()
{
	//Don't do anything requiring controllers here!
}
defaultproperties
{
	fAquireBaseAttackSkill_Label=" Base Attack "
	fAquireDummyMod_Label=" Dummy Mod "
	fAquireDummySkill_Label=" Dummy Skill "
	fAquireskill_BlinkSpeed_Label=" Blink Speed "
	fAquireskill_CamJam_Label=" Cam Jam "
	fAquireskill_Defocus_Label=" Defocus "
	fAquireskill_ECM_Label=" ECM "
	fAquireskill_FireArmsTargeting_Label=" Fire Arms "
	fAquireskill_Fireball_Label=" Fireball "
	fAquireskill_Fireball_Projectile_Label=" Fireball Proj "
	fAquireskill_FireFist_Label=" Fire Fist "
	fAquireskill_FireShield_Label=" Fire Shield "
	fAquireskill_Hacking_Label=" Hacking "
	fAquireskill_Healing_Label=" Healing "
	fAquireskill_HeavenBlast_Label=" Heaven Blast"
	fAquireskill_HeavyWeaponsTargeting_Label=" Hvy Weapons "
	fAquireskill_HydroCloak_Label=" Hydro Cloak "
	fAquireskill_HydroShock_Label=" Hydro Shock "
	fAquireskill_IceFist_Label=" Ice Fist "
	fAquireskill_IceShards_Label=" Ice Shards "
	fAquireskill_Jumping_Label=" Jumping "
	fAquireskill_meleeCombat_Label=" Melee Combat "
	fAquireskill_OpticCloak_Label=" Optic Cloak "
	fAquireskill_RockFist_Label=" Rock Fist "
	fAquireskill_RockGrenade_Label=" Rock Grenade "
	fAquireskill_RockShards_Label=" Rock Shards "
	fAquireskill_urbanTracking_Label=" Urban Tracking "
}