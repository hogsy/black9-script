//=============================================================================
// SwarmGun2
//
// 
//
// 
//=============================================================================

class SwarmGun2 extends B9HeavyWeapon;

#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX

//#exec TEXTURE IMPORT NAME=SwarmGunIcon FILE=Textures\SwarmGunIcon.bmp

simulated function PlayFiring()
{
	//Play firing animation and sound
	LoopAnim('Fire1');
	IncrementFlashCount();
}

simulated function PlayAltFiring()
{
	//Play alt firing animation and sound
	LoopAnim('Fire2');
}

simulated function PlayIdleAnim()
{
	LoopAnim('Still');
}

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	if ( !IsAnimating() ) //|| (AnimSequence != 'Select') )
		PlayAnim('Still',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, 1.0);	
}

// This function is called by an actor that wants to use ammo.  
// Return true if ammo exists 
//
function bool UseAmmo(int AmountNeeded)
{
	
	//if (AmmoType.AmmoAmount < AmountNeeded) return False;   // Can't do it
	//AmmoType.AmmoAmount -= AmountNeeded;
	return True;
}

simulated function bool RepeatFire()
{
	return true;
}

function ServerFire()
{
	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.HasAmmo() )
	{
		GotoState('NormalFire');
		LocalFire();
	}
}

///////////////////////////////////////////////////////

state NormalFire
{
	ignores AnimEnd;
Begin:
FireRocket:
	
	Log( "Thinking about firing: " $ string(ReloadCount) $ "/" $ string(AmmoType.AmmoAmount) );

	if ( ReloadCount > 0 )
	{
		Log( "Should be firing" );

		Sleep( 0.15 );
		ReloadCount--;
//		ClientFire(0);
		ProjectileFire( );
		PlaySound( sound'prot_gun_firing_4', SLOT_None, 1.0f, false );
		Goto('FireRocket');
	}
	Sleep(1.5);
	Log( "Going to Reloading: " $ string(ReloadCount) $ "/" $ string(AmmoType.AmmoAmount) );
	GotoState('Reloading');
	//Finish();
}

defaultproperties
{
	fUniqueID=26
	AmmoName=Class'SwarmGunAmmunition'
	PickupAmmoCount=100
	ReloadCount=6
	bRapidFire=true
	AutoSwitchPriority=4
	MaxRange=12000
	InventoryGroup=4
	PickupClass=Class'SwarmGun2_Pickup'
	AttachmentClass=Class'AttachmentSwarmGun2'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_armature_gun_bricon'
	ItemName="Swarmer Launcher"
	Mesh=SkeletalMesh'B9Weapons_models.bazooka'
}