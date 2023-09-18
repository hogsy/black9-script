//=============================================================================
// SwarmGun
//
// 
//
// 
//=============================================================================

class SwarmGun extends B9WarfareWeapon;

#exec OBJ LOAD FILE=..\animations\B9Weapons_models.ukx PACKAGE=B9Weapons_models
#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX

#exec TEXTURE IMPORT NAME=SwarmGunIcon FILE=Textures\SwarmGunIcon.bmp

simulated function PlayFiring()
{
	//Play firing animation and sound
	IncrementFlashCount();
	LoopAnim('Fire1');
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

///////////////////////////////////////////////////////

state NormalFire
{
	ignores AnimEnd;
Begin:
FireRocket:
	
	Log( "Thinking about firing" );

	if ( ReloadCount > 0 )
	{
		Log( "Should be firing" );

		Sleep( 0.15 );
		ReloadCount--;
//		ClientFire(0);
		ProjectileFire( /* ProjectileClass, bWarnTarget, bRecommendSplashDamage */);
		PlaySound( sound'prot_gun_firing_4', SLOT_None, 1.0f, false );
		Goto('FireRocket');
	}
	Sleep(1.5);
	Finish();
}

defaultproperties
{
	AmmoName=Class'SwarmGunAmmunition'
	PickupAmmoCount=100
	ReloadCount=6
	bRapidFire=true
	AutoSwitchPriority=4
	InventoryGroup=4
	PickupClass=Class'SwarmGunPickup'
	AttachmentClass=Class'AttachmentSwarmGun'
	Icon=Texture'B9HUD_textures.Browser.SwarmGun_BrIcon_tex'
	ItemName="Swarmer Launcher"
	Mesh=SkeletalMesh'B9Weapons_models.bazooka'
}