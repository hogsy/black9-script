//=============================================================================
// B9_PlayerPawn
//
// PlayerPawns are the physical body of B9_PlayerControllers
//
// 
//=============================================================================

class B9_PlayerPawn extends B9_BasicPlayerPawn;	

#exec OBJ LOAD FILE=..\StaticMeshes\B9_Weapons_meshes.usx PACKAGE=B9_Weapons_meshes
#exec OBJ LOAD FILE=..\textures\programmer_art_JP.utx PACKAGE=programmer_art_JP

var travel private int	fSelectedWeaponID;
var travel private int	fSelectedItemID;
var travel private int	fSelectedSkillID;

/*
var byte fAddInvNo;
var byte fLastInvNo;
var bool fUpdateInv;
var float fHyperUpdateInv;
*/

var name fServerName;
var name fHQPickupTag;

/* PointOfView()
called by controller when possessing this pawn
false = 1st person
true = 3rd person
*/

var public name fCurrentWeaponBone;

var public float fSpecialEyeHeight;

var class<B9InventoryItem> InventoryItemClass;

var() StaticMesh Helmet;
var class<B9_HelmetAttachment> HelmetClass;
var B9_HelmetAttachment HelmetActor;
var name HelmetBone;

var() StaticMesh BackPack;
var class<B9_HelmetAttachment> BackPackClass;
var B9_HelmetAttachment BackPackActor;
var name BackPackBone;

var material AffiliationSkins[16]; // [4 per affiliation]

replication
{
	// Variables the server should send to the client.

	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		 fServerName;

	reliable if( Role==ROLE_Authority )
		CreateInventoryBrowser, DeleteFromInventoryBrowser, EmptyInventoryBrowser,
		ReadoutSubject;

	// HQ-based changes client makes to server.
	reliable if( Role<ROLE_Authority )
		HQSellItem, HQBuyItem, HQAddSkill, HQModifySkill, HQApplyMods, HQQueryResultWithLocation,
		HQAddAttrCalibration, HQAddNanoCalibration;

	// Server functions we want to call from the client
	reliable if( Role < ROLE_Authority )
		ServerChangeSkill, ServerChangeItem;

}

// Forward declartions



function PreBeginPlay()
{
	Super.PreBeginPlay();
//	log("PreBegin Play Called For B9_PlayerPawn");
	fCurrentWeaponBone = 'Bip01 R Hand';
	fServerName = Name;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.bNeedSpacesuit)
		SetHelmet();
}

function ClientReStart()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	if (fSpecialEyeHeight != 0.0f)
		BaseEyeHeight = fSpecialEyeHeight;
	else
		BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	PlayWaiting();
}

function Untrigger( actor Other, pawn EventInstigator )
{
	if ( Controller != None )
		Controller.Untrigger(Other, EventInstigator);
}

simulated function bool PointOfView()
{
	return true;
}

function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	if ( PhysicsVolume.bWaterVolume )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking); 
}

function SetWalking(bool bNewIsWalking)
{
	if ( bNewIsWalking != bIsWalking )
	{
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
}

/* SpecialJumpAnim()
Return true if currently playing a special jump animation which shouldn't be interrupted when landing
*/
function bool SpecialJumpAnim()
{
	return ( AnimIsInGroup(0,'Dodge') );
}

function bool IsPlayingLanding()
{
	return ( AnimIsInGroup(0,'Landing') );
}

function bool IsGesturing()
{
	return ( AnimIsInGroup(0,'Gesture') );
}
/*
function TweenToGesture( int num, float tweenTime )
{
}
*/
function PlayGesture( int num, float tweenTime )
{
}



function name GetWeaponBoneFor(Inventory I)
{
	return fCurrentWeaponBone;
//	return 'Bip01 R Hand';
}

simulated function AddToInventoryBrowser(Inventory NewItem)
{
	local B9InventoryItem	item;
	local B9_Powerups		pwrup;
	local B9_Skill			skill;
	
//	Log("A2IB: "$NewItem);

	if (fInventoryBrowser != None)
	{
		skill = B9_Skill( NewItem );
		if( skill != None && skill.fActivatable )
		{
//			log("Adding Skill");
			item = new(none) class'B9InventoryItem';
			item.fMaterial	= skill.Icon;
			item.fSortOrder	= skill.fUniqueID;
			
			fInventoryBrowser.AddSkill( item );

			// If this is the first skill to be added, make sure we
			// update the selection status
			//
//			if( fSelectedSkill == None )
//			{
//				log("Updating the Skill Selection");
				fSelectedSkill		= skill;
				fSelectedSkillID	= skill.fUniqueID;
				fInventoryBrowser.SetSelectedSkill( fSelectedSkillID );	
//			}
		}
		else if( NewItem.IsA( 'B9WeaponBase' ) )
		{
			// Add weapon with specificsx
			//
//			log("Adding Weapon");
			item = new(none) class'B9InventoryItem';
			item.fMaterial	= NewItem.Icon;
			item.fSortOrder = B9WeaponBase(NewItem).fUniqueID;
			fInventoryBrowser.AddWeapon( item );

			if( Weapon == None )
			{
//				PlayerController( Controller ).SwitchWeapon( B9WeaponBase(NewItem).fUniqueID );
//				fSelectedSkillID	= skill.fUniqueID;
//				fInventoryBrowser.SetSelectedSkill( fSelectedSkillID );
			}
		}
		else if( NewItem.IsA( 'B9_Powerups' ) )
		{
			// Add item with specifics
			//
//			log("Adding Powerups");
			item = new(none) class'B9InventoryItem';
			item.fMaterial	= NewItem.Icon;

			pwrup = B9_Powerups( NewItem );
			if( pwrup != none && pwrup.bActivatable )
			{
				item.fSortOrder = pwrup.fUniqueID;
				fInventoryBrowser.AddItem( item );

				//if( SelectedItem == None )
				//{
//					log("Updating the PowerUp Selection");
					SelectedItem = pwrup;
				//}
			}
		}
	}
}

/*
function FinishAddToInventoryBrowser()
{
	local Inventory Inv;
	local int i;

	if (fInventoryBrowser == None)
	{
		CreateInventoryBrowser();
	}

	if (fInventoryBrowser != None)
	{
		for( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
		{
			Log("FinishAddToInventoryBrowser: "$Inv);
			if( Inv.IsA( 'B9_Skill' ) && B9_Skill(Inv).fActivatable)
			{
				if (!fInventoryBrowser.QuerySkillID( B9_Skill(Inv).fUniqueID ))
				{
					AddToInventoryBrowser( Inv );
				}
			}
			else if( Inv.IsA( 'B9WeaponBase' ))
			{
				if (!fInventoryBrowser.QueryWeaponID( B9WeaponBase(Inv).fUniqueID ))
				{
					AddToInventoryBrowser( Inv );
				}
			}
			else if( Inv.IsA( 'B9_Powerups' ))
			{
				if (!fInventoryBrowser.QueryItemID( B9_PowerUps(Inv).fUniqueID ))
				{
					AddToInventoryBrowser( Inv );
				}
			}

			i++;
		}

	}
}
*/

function bool AddInventory( inventory NewItem )
{
	local bool				success;
	local B9_Powerups		pwrup;
	local B9_Skill			skill;
	local bool				isWeapon;

	isWeapon = NewItem.IsA( 'weapon' );

	// Limit 3 weapons per customer
	//
	if( isWeapon && fWeaponCount >= kMaxPlayerWeapons && !NewItem.IsA( 'GrapplingHook' ) )
	{
		return false;
	}

	success = Super.AddInventory( NewItem );

	if (success)
	{
		if ( fInventoryBrowser == none &&
			(Level.NetMode == NM_Standalone || Level.NetMode == NM_ListenServer) )
		{
			CreateInventoryBrowser();
		}

		if (fInventoryBrowser != none)
		{
			AddToInventoryBrowser( NewItem );
		}
//		else
//		{
//			fAddInvNo++;
//		}

		if( isWeapon )
		{
			fWeaponCount++;
		}
	}

	return success;
}

simulated function DeleteFromInventoryBrowser(Inventory Item)
{
	local B9_Skill	b9skill;

	if ( fInventoryBrowser != none )
	{
//		Log("DFIB: "$Item);
		
		if( Item.IsA( 'B9WeaponBase' ) )
		{
			fInventoryBrowser.RemoveWeapon( B9WeaponBase(Item).fUniqueID );
		}
		
		else if( Item.IsA( 'B9_Powerups' ) )
		{
			fInventoryBrowser.RemoveItem( B9_Powerups( Item ).fUniqueID );
		}
	
		else if( Item.IsA( 'B9_Skill' ) )
		{
			b9skill = B9_Skill( Item );
			if( b9skill != none && b9skill.fActivatable)
			{
				fInventoryBrowser.RemoveSkill( b9skill.fUniqueID );
			}
		}
	}
}

// Remove Item from this pawn's inventory, if it exists.
function DeleteInventory( inventory Item )
{
	DeleteFromInventoryBrowser( Item );
	Super.DeleteInventory( Item );

	if( Item.IsA( 'weapon' ) )
	{
		fWeaponCount--;
	}
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	SpewInventory();
	Super.Died( Killer, damageType, HitLocation );
}

function CleanupAfterKilled()
{
	EmptyInventoryBrowser();
	fWeaponCount = 0;
}

function TossWeapon(vector TossVel)
{
	local vector X,Y,Z;

	if( B9WeaponBase( Weapon ).fUniqueID != wepID_MeleeHandToHand )
	{
		Super.TossWeapon( TossVel );
	}
}	

function SpewInventory()
{
	local Inventory Inv, InvNext;

	if( Level.NetMode == NM_Client )
		return;
	
	Inv = Inventory;
	while( Inv != None )
	{
		InvNext = Inv.Inventory;
		if( !Inv.IsA( 'B9_Skill' ) && B9WeaponBase( Inv ).fUniqueID != wepID_MeleeHandToHand )
		{
			SpewInventoryItem( Inv, true );
		}
		Inv = InvNext;
	}
}

function SpewInventoryItem( Inventory Inv, bool bRandomVelocity )
{
	local vector	v, v2, X, Y, Z;

	if( bRandomVelocity )
	{
		v.X = Rand(200);
		v.Y = Rand(200);
		v.Z = Rand(200);
	}
	else
	{
		v.X = 0;
		v.Y = 0;
		v.Z = 220;
	}

	GetAxes(Rotation,X,Y,Z);
	v2				= Vector(Rotation) * 500 + v;
	Inv.velocity	= v2;
	Inv.bTossedOut	= true;
	Inv.DropFrom( Location + 0.8 * CollisionRadius * X + - 0.5 * CollisionRadius * Y );
}

function InventoryDrop()
{
	local int			selectedColumn, itemID;
	local Inventory		Inv;
	local B9_Powerups	pPowerup;
	local B9WeaponBase	pWep;

	if( !fInventoryBrowser.IsSelectorActive() )
	{
		return;
	}

	selectedColumn = fInventoryBrowser.GetSelectedColumn();
	
	if( selectedColumn == 0 )
	{
		itemID = fInventoryBrowser.GetSelectedWeapon();

		for( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
		{
			pWep = B9WeaponBase( Inv );
			if( ( pWep != none ) && ( pWep.fUniqueID == itemID ) && ( pWep.fUniqueID != wepID_MeleeHandToHand ) )
			{
				SpewInventoryItem( pWep, false );
			}
		}

		itemID = fInventoryBrowser.GetSelectedWeapon();
		PlayerController( Controller ).SwitchWeapon( itemID );
		fSelectedWeaponID = itemID;
	}

	else if( selectedColumn == 1 ) // item
	{
		pPowerup = B9_Powerups( SelectedItem );
		SpewInventoryItem( SelectedItem, false );

		itemID = fInventoryBrowser.GetSelectedItem();
		
		for( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
		{
			pPowerup = B9_Powerups( Inv );
			if( ( pPowerup != none ) && ( pPowerup.fUniqueID == itemID ) )
			{
				SelectedItem = pPowerup;
				break;
			}
		}
	}
}


simulated event Tick( float deltaTime )
{
	local B9_PlayerController C;
	local int i;

	C = B9_PlayerController( Controller );

/*
	if (fHyperUpdateInv > 0.0f)
	{
		fHyperUpdateInv -= deltaTime;
		if (fHyperUpdateInv <= 0.0f)
		{
			fHyperUpdateInv = 0.0f;
			FinishAddToInventoryBrowser();
		}
	}
	if (fUpdateInv && C != None)
	{
		FinishAddToInventoryBrowser();
		fUpdateInv = false;
		fHyperUpdateInv = 5.0f; // extra sanity check
	}
	if (fAddInvNo != fLastInvNo)
	{
		fUpdateInv = true;
		fLastInvNo = fAddInvNo;
	}
*/

	UpdateInventoryBrowser();


	// Update B9_AdvancedPawn with skill button info
	// That way, AI & Human can use the same function call down on the Skill level
	//
	if( C != None && C.bSkill != 0 )
	{
		fUsingConstantSkill = true;
	}
	else
	{
		fUsingConstantSkill = false;
	}

	Super.Tick( deltaTime );
}


// Driven by Tick()
// Keeps track of things, like changing selected items
//
function UpdateInventoryBrowser()
{
	local int			newItmID;
	local weapon		newWep;
	local B9_Powerups	newPowerup;
	local Inventory		Inv;
	local B9_Skill		skill;
	local B9WeaponBase	wep;


	if( fInventoryBrowser != none )
	{
		fInventoryBrowser.Update();


		if( fInventoryBrowser.NeedToSwitchWeapon() )
		{
			PlayerController( Controller ).SwitchWeapon( fInventoryBrowser.GetSelectedWeapon() );
			fSelectedWeaponID = newItmID;
		}
		else
		{
			wep = B9WeaponBase( Weapon );
			if( wep != None && !fInventoryBrowser.fWeaponSwitching && fInventoryBrowser.GetSelectedWeapon() != wep.fUniqueID )
			{
				PlayerController( Controller ).SwitchWeapon( fInventoryBrowser.GetSelectedWeapon() );
				fSelectedWeaponID = newItmID;
			}
		}

		if( fInventoryBrowser.NeedToSwitchItem() )
		{
			newItmID = fInventoryBrowser.GetSelectedItem();
			ServerChangeItem( newItmID );
		}

		if( fInventoryBrowser.NeedToSwitchSkill() || fSelectedSkill == None )
		{
			newItmID = fInventoryBrowser.GetSelectedSkill();
			ServerChangeSkill( newItmID );
		}
	}
}

simulated function EmptyInventoryBrowser()
{
	if( fInventoryBrowser != none )
		fInventoryBrowser.ClearAll();
	fSelectedWeaponID = 0;
	fSelectedItemID = 0;
	fSelectedSkillID = 0;
	fSelectedSkill = None;
}

// Call from PostTravelAccept to reload the player's stuff
//
simulated function CreateInventoryBrowser()
{
	local B9InventoryItem	itm;
	local Inventory			Inv;
	local B9_Powerups		pwrup;
	local B9_Skill			skill;
	local PlayerController player;

	// Create the browser itself
	//
	if( fInventoryBrowser == none )
	{
		// For some reason the old inventory browser
		// may stay around, and cause duplicated copies
		// to be used in the code. So let's find it if
		// it is around
		player = PlayerController( Controller );

		ForEach player.AllActors( class'B9InventoryBrowser', fInventoryBrowser)
		{
			Log("XT: Old inventory browser is still in use. Grabbing it for the new pawn."); 
			Log("    If this causes left over inventories to be added into current one, this."); 
			Log("    needs to be changed. This is in B9_PlayerPawn.uc, on line 607 "); 
			break;
		}

		if( fInventoryBrowser == none )
		{
			fInventoryBrowser = Spawn(class'B9InventoryBrowser');
			if( fInventoryBrowser == none )
			{
				Log( "Failed to create fInventoryBrowser" );
				return;
			}
		}
		fInventoryBrowser.RemoteRole = ROLE_None;
		fInventoryBrowser.SetOwner( Self );
	}


	// Iterate through Inventory and add items to the Browser
	//
	for( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
	{
		// Create a generic item
		//
		itm = new(none) class'B9InventoryItem';
		itm.fMaterial	= Inv.Icon;
		
		
		// Is it a weapon?
		//
		if( Inv.IsA( 'B9WeaponBase' ) )
		{
			itm.fSortOrder = B9WeaponBase(Inv).fUniqueID;
			fInventoryBrowser.AddWeapon( itm );
		}
		
		// Is it an item?
		//
		else if( Inv.IsA( 'B9_Powerups' ) )
		{
			pwrup = B9_Powerups( Inv );
			if( pwrup != none && pwrup.bActivatable )
			{
				itm.fSortOrder = pwrup.fUniqueID;
				fInventoryBrowser.AddItem( itm );
			}
		}

		// Is it a skill?
		//
		else if( Inv.IsA( 'B9_Skill' ) )
		{
			skill = B9_Skill( Inv );
			if( skill != None && skill.fActivatable )
			{
				itm.fSortOrder = skill.fUniqueID;
				fInventoryBrowser.AddSkill( itm );
				
				// If this is the first skill to be added, make sure we
				// update the selection status
				//
				if( fSelectedSkill == None )
				{
					fSelectedSkill		= skill;
					fSelectedSkillID	= skill.fUniqueID;
				}
			}
		}
	}

	// Restore the selected items to selected status
	//
	fInventoryBrowser.SetSelectedWeapon( fSelectedWeaponID );
	fInventoryBrowser.SetSelectedItem( fSelectedItemID );
	fInventoryBrowser.SetSelectedSkill( fSelectedSkillID );
}

function ServerChangeSkill( int skillID )
{
	local Inventory		Inv;
	local B9_Skill		skill;

	for( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
	{
		skill = B9_Skill( Inv );
		if( skill != None && skill.fActivatable && skill.fUniqueID == skillID )
		{
			fSelectedSkill = skill;
		}
	}
}

function ServerChangeItem( int itemID )
{
	local Inventory		Inv;
	local B9_Powerups	prp;

	for( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
	{
		prp = B9_Powerups( Inv );
		if( prp != None && prp.bActivatable && prp.fUniqueID == itemID )
		{
			SelectedItem = prp;
		}
	}
}

simulated event RenderOverlays( canvas Canvas )
{
	if(  fSelectedSkill != none )
	{
		fSelectedSkill.RenderOverlays( Canvas );
	}
}

// The following functions are needed to support HQ operations.

simulated function HQSellItem(Inventory inv, int price) // price is full price, ConfirmSellItem will adjust
{
	local B9_CalibrationMaster CalMaster;

	if (inv == None || inv.Owner != self || price == 0) // sanity check
		return;

	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		if (!CalMaster.ConfirmSellItem(""$inv.Class.Name, price))
			CalMaster = None;
		break;
	}
	if (CalMaster == None)
		return;

	if (inv == Weapon)
		ServerChangedWeapon(Weapon, None);
	DeleteInventory(inv);
	inv.Destroy();

	fCharacterCash += price;
}

simulated function HQBuyItem(string invName, int price, name DropTagName)
{
	local Actor A, B;
	local float dist, Bdist;
	local B9_CalibrationMaster CalMaster;
	local B9_HoloItem Item;
	local Pickup Pickup;
	local Inventory Inv;
	local bool ok;

	if (price > fCharacterCash) // sanity check
		return;

	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		if (!CalMaster.ConfirmBuyItem(invName, price))
			CalMaster = None;
		break;
	}
	if (CalMaster == None)
		return;

	Item = Spawn(class<B9_HoloItem>(DynamicLoadObject(invName $ "_Holo", class'Class')));
	if (Item == None)
		return;

	ok = Item.RequiredStrength == 0 || Item.RequiredStrength <= fCharacterStrength;
	Item.Destroy();
	Item = None;

	if (!ok)
		return;

/*
	if (CalMaster.ShouldDirectPurchase())
	{
*/
		A = Instigator; // Set Instigator to None to keep pickups from exploding when spawned.
		Instigator = None;
		Pickup = Spawn( class<Pickup>(DynamicLoadObject(invName $ "_Pickup", class'Class')) );
		Instigator = Pawn(A);
		if (Pickup != None)
		{
			if (Inventory == None || !Inventory.HandlePickupQuery( Pickup ))
			{
				Inv = Spawn( class<Inventory>(DynamicLoadObject(invName, class'Class')) );
				if (Inv != None) Inv.GiveTo(self);
			}
			Pickup.Destroy();
		}
/*
	}
	else
	{
		// !!!! may want to fuzz location, or not since this is not how the items are dropped
		B = None;
		Bdist = 100000.0f;
		ForEach AllActors(class'Actor', A, DropTagName)
		{
			dist = VSize(A.Location - Location);
			if (dist < Bdist)
			{
				B = A;
				Bdist = dist;
			}
		}

		if (B == None)
			return;

		Pickup = Spawn(class<Pickup>(DynamicLoadObject(invName $ "_Pickup", class'Class')), ,
			fServerName, B.Location , B.Rotation);
	}
*/

	fCharacterCash -= price;
}

function int CountSkills(Inventory Inv)
{
	local int n;

	while (Inv != None)
	{
		if (B9_Skill(Inv) != None) n++;
		Inv = Inv.Inventory;
	}
	return n;
}

function HQAddSkill(String InvName)
{
	local class<Inventory> InvClass;
	local int Price;

	InvClass = class<Inventory>(DynamicLoadObject(InvName, class'Class'));
	if (FindInventoryType(InvClass) != None)
		return;

	Price = CountSkills(Inventory);
	if (Price < 5) Price = 5;
	if (Price > fCharacterSkillPoints) // sanity check
		return;

	fCharacterSkillPoints -= Price;
	AddInventory(Spawn(InvClass));
	ApplyModifications();
}

function HQModifySkill(String InvName, int Points)
{
	local class<Inventory> InvClass;
	local B9_Skill skill;
	local int Price;

	Price = Points;
	if (Price > fCharacterSkillPoints) // sanity check
		return;

	InvClass = class<Inventory>(DynamicLoadObject(InvName, class'Class'));
	skill = B9_Skill(FindInventoryType(InvClass));
	if (skill == None)
		return;

	fCharacterSkillPoints -= Price;
	skill.fStrength += Points;
	ApplyModifications();
}

simulated function HQAddBodyModCalibration(string invName, int price)
{
	local B9_CalibrationMaster CalMaster;

	if (price > fCharacterCash) // sanity check
		return;

	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		if (!CalMaster.ConfirmBuyMod(invName, price))
			CalMaster = None;
		break;
	}
	if (CalMaster == None)
		return;

	CalMaster.AddBodyModCalibration(Name, invName, price);
	fCharacterCash -= price;
}

simulated function HQQueryResultWithLocation(vector Location, bool Result)
{
	local B9_CalibrationMaster CalMaster;

	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		CalMaster.QueryResultWithLocation(self, Location, Result);
		break;
	}
}

simulated function HQApplyMods()
{
	local B9_CalibrationMaster CalMaster;

	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		CalMaster.MakePermanent(self);
		Controller.Trigger(CalMaster, self);
		break;
	}
}

simulated function HQAddAttrCalibration(byte type, int points, int adjustment)
{
	local B9_CalibrationMaster CalMaster;

	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		CalMaster.AddAttrCalibration(self, type, points, adjustment);
		break;
	}
}

simulated function HQAddNanoCalibration(B9_Skill skill, int points, int adjustment)
{
	local B9_CalibrationMaster CalMaster;

	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		CalMaster.AddNanoCalibration(self, skill, points, adjustment);
		break;
	}
}

simulated function ReadoutSubject(name ReadoutTag, bool set)
{
	local Actor Readout;

	ForEach AllActors(class'Actor', Readout, ReadoutTag)
	{
		if (set) Readout.Trigger(self, self);
		else readout.Untrigger(self, self);
		break;
	}
}


function SetMultiplayer()
{
	fCharacterConcludedMission = kMultiplayerMissionType;
}


function SetConcludedMission( int mission )
{
	fCharacterConcludedMission = mission;
}


function AddMissionObjective( B9MissionObjective objective )
{
	fMissionObjectives.Length = fMissionObjectives.Length + 1;
	fMissionObjectives[fMissionObjectives.Length - 1] = objective;
	
	B9_PlayerController( Controller ).ShowLocationMessage( "Mission Objectives Updated" );
}


function CompleteMissionObjective( B9MissionObjective objective )
{
	B9_PlayerController( Controller ).ShowLocationMessage( "Mission Objective Completed" );
}

function SetupForMission()
{
	fAcquiredSkillPoints = 0;
	fAcquiredCash = 0;
}

function TogglePDA()
{
	local B9_HUD	b9HUD;

	b9HUD = B9_HUD( PlayerController( Controller ).myHUD );
	if( b9HUD == none )
	{
		return;
	}

	b9HUD.ToggleTempPDA();
}

function SetHelmet() // also set backpack
{
	if ( HelmetActor == None )
	{
		HelmetActor = Spawn(HelmetClass, Owner);
		HelmetActor.SetDrawScale(HelmetActor.DrawScale * DrawScale);
	}
	
	if (HelmetActor.AttachmentBone == HelmetBone)
	{
		DetachFromBone(HelmetActor);
		HelmetActor.SetStaticMesh(None);
	}
	else
	{
		HelmetActor.SetStaticMesh(Helmet);
		AttachToBone(HelmetActor, HelmetBone);
	}

	if (BackPack != None)
	{
		if ( BackPackActor == None )
		{
			BackPackActor = Spawn(BackPackClass, Owner);
			BackPackActor.SetDrawScale(BackPackActor.DrawScale * DrawScale);
		}
		
		if (BackPackActor.AttachmentBone == BackPackBone)
		{
			DetachFromBone(BackPackActor);
			BackPackActor.SetStaticMesh(None);
		}
		else
		{
			BackPackActor.SetStaticMesh(BackPack);
			AttachToBone(BackPackActor, BackPackBone);
		}
	}
}

simulated event SetSkin()
{
	local int n;

	Log("SetSkin to "$SkinIndex);

	if (Skins.Length == 0 )
	{
		CopyMaterialsToSkins();
	}

	n = 4 * SkinIndex;
	Skins[0] = AffiliationSkins[n];
	Skins[1] = AffiliationSkins[n + 1];
	Skins[2] = AffiliationSkins[n + 2];
	Skins[3] = AffiliationSkins[n + 3];
}


function bool IsPlayer()
{
	return false;
}



defaultproperties
{
	fHQPickupTag=HQPickupTag
	fCurrentWeaponBone=weaponbone
	InventoryItemClass=Class'B9Inventory.B9InventoryItem'
	HelmetClass=Class'B9_HelmetAttachment'
	HelmetBone=SpaceSuitBone1
	BackPackClass=Class'B9_HelmetAttachment'
	BackPackBone=SpaceSuitBone2
	kMultiplayerMissionType=-1
	fCharacterCash=188888
	fCharacterSkillPoints=20
	bWeaponUsesAmmo=true
	bDoApplyModifications=true
	fFaction=4
	bCanCrouch=true
	bCanClimbLadders=true
	bCanWalkOffLedges=true
	bCanPickupInventory=true
	ControllerClass=none
	bActorShadows=true
	bReplicateSkinIndex=true
}