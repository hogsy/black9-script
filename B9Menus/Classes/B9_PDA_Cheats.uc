class B9_PDA_Cheats extends B9_MenuPDA_Menu;

var localized string fGodLabel;
var localized string fFlyLabel;
var localized string fGhostLabel;
var localized string fWalkLabel;
var localized string fSummonLabel;
var localized string fHealLabel;
var localized string fGiveCashLabel;
var localized string fAquireSkillLabel;
var localized string fDropAllInventoryLabel;
var localized string fTravelToMapLabel;

var bool fGhostModeOn;
var bool fFlyModeOn;

// Event IDs
const kEvent_God	= 0;
const kEvent_Fly	= 1;
const kEvent_Ghost	= 2;
const kEvent_Walk	= 3;
const kEvent_Heal	= 4;
const kEvent_GiveCash = 5;
const kEvent_AquireSkill = 6;
const kEvent_DropAllInventory = 7;

function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;
	local displayitem_GenericMenuItem newMenuItem;
	//log("DO we have a RootController?"$fPDABase.RootController);

	fReturnMenu = class'B9_PDA_Pause_OptionsMenu';
	
	//God
	newItem = new(None)class'displayItem';
	newItem.fLabel = fGodLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_God;
	AddDisplayItem( newItem );
	
	//Fly
	newItem = new(None)class'displayItem';
	newItem.fLabel = fFlyLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Fly;
	AddDisplayItem( newItem );
	
	//Ghost
	newItem = new(None)class'displayItem';
	newItem.fLabel = fGhostLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Ghost;
	AddDisplayItem( newItem );
	
	//Walk
	newItem = new(None)class'displayItem';
	newItem.fLabel = fWalkLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Walk;
	AddDisplayItem( newItem );
	
	// Summon Weapon
	newMenuItem = new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel = fSummonLabel;
	newMenuItem.fMenuClass = class'B9_PDA_Cheats_Summon';
	AddDisplayItem( newMenuItem );

	//Heal
	newItem = new(None)class'displayItem';
	newItem.fLabel = fHealLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Heal;
	AddDisplayItem( newItem );

	//Get Cash
	newItem = new(None)class'displayItem';
	newItem.fLabel = fGiveCashLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_GiveCash;
	AddDisplayItem( newItem );

	// Aquire Skill
	newMenuItem = new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel = fAquireSkillLabel;
	newMenuItem.fMenuClass = class'B9_PDA_Cheats_Skills';
	AddDisplayItem( newMenuItem );

	// Drop All Stuff
	newItem = new(None)class'displayitem';
	newItem.fLabel = fDropAllInventoryLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_DropAllInventory;
	AddDisplayItem( newItem );

	// Go to travel to map
	newMenuItem = new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel = fTravelToMapLabel;
	newMenuItem.fMenuClass = class'B9_PDA_Cheats_Map';
	AddDisplayItem( newMenuItem );
	
}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		case kEvent_God:
			On_GodMode();
		break;
		
		case kEvent_Fly:
			On_Fly();
		break;
		
		case kEvent_Ghost:
			On_Ghost();			
		break;
		
		case kEvent_Walk:
			On_Walk();			
		break;

		case kEvent_Heal:
			On_HealCharacter();
		break;

		case kEvent_GiveCash:
			GiveCharacterCash();
		break;

		case kEvent_DropAllInventory:
			DropAllStuff();
		break;
	}
}

function On_GodMode()
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "god" );
}

function On_Fly()
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "fly" );
}

function On_Ghost()
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "ghost" );
}

function On_Walk()
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "walk" );
}
function On_HealCharacter()
{
	local B9_AdvancedPawn		OwnerPawn;

 	fPDABase.AddMenu( None, None );
	OwnerPawn			= B9_PlayerControllerBase( fPDABase.RootController ).GetAdvancedPawn();
	OwnerPawn.Health = OwnerPawn.fCharacterMaxHealth;
}
function GiveCharacterCash()
{
	local B9_AdvancedPawn		OwnerPawn;
	local B9_BasicPlayerPawn	basicPlayerPawn;
 	fPDABase.AddMenu( None, None );
	OwnerPawn			= B9_PlayerControllerBase( fPDABase.RootController ).GetAdvancedPawn();
	basicPlayerPawn = B9_BasicPlayerPawn( OwnerPawn );

	basicPlayerPawn.fCharacterCash += 1000000;
}
function DropAllStuff()
{
	local B9_AdvancedPawn		OwnerPawn;
	local B9_PlayerPawn			myPlayerPawn;
	local Inventory Inv, InvNext;

 	fPDABase.AddMenu( None, None );
	OwnerPawn			= B9_PlayerControllerBase( fPDABase.RootController ).GetAdvancedPawn();
	myPlayerPawn		= B9_PlayerPawn( OwnerPawn );

	Inv = myPlayerPawn.Inventory;

	while( Inv != None )
	{
		InvNext = Inv.Inventory;

		if( B9WeaponBase( Inv ).fUniqueID != wepID_MeleeHandToHand )
		{
			myPlayerPawn.SpewInventoryItem( Inv, true );
		}
		Inv = InvNext;
	}
}
function Initialize()
{
	//Don't do anything requiring controllers here!
}

defaultproperties
{
	fGodLabel="God Mode"
	fFlyLabel="Fly"
	fGhostLabel="Ghost"
	fWalkLabel="Walk (Turns off Ghost and Fly)"
	fSummonLabel="Summon Weapon"
	fHealLabel="Heal Your Character"
	fGiveCashLabel="Get Cash"
	fAquireSkillLabel="Aquire Skill"
	fDropAllInventoryLabel="Drop All Players Inventory"
	fTravelToMapLabel="Travel To Map"
}