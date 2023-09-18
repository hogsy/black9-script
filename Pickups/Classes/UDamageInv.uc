class UDamageInv extends Powerups;


var Weapon UDamageWeapon;
var sound ExtraFireSound;
var sound EndFireSound;
var int FinalCount;

singular function UsedUp()
{
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		UDamageWeapon.Affector = None;
	}
	if ( Owner != None )
	{
		if ( Pawn(Owner).Controller != None )
		{
			if ( !Pawn(Owner).IsPlayerPawn() || (Pawn(Owner).PlayerReplicationInfo.HasFlag == None) )
			{
				Owner.AmbientGlow = Owner.Default.AmbientGlow;
				Owner.LightType = LT_None;
				Owner.bDynamicLight = false;
			}
			Pawn(Owner).DamageScaling = 1.0;
		}
		bActive = false;
		if ( Owner.Inventory != None )
		{
			Owner.Inventory.SetOwnerDisplay();
			Owner.Inventory.OwnerEvent('ChangedWeapon');
		}
	}
	Destroy();
}

simulated function FireEffect()
{
	if ( (TimerRate - TimerCounter < 5) && (Level.NetMode != NM_Client) )
		Pawn(Owner).Weapon.PlayOwnedSound(EndFireSound, SLOT_Interact, 8);
	else 
		Pawn(Owner).Weapon.PlayOwnedSound(ExtraFireSound, SLOT_Interact, 8);
}

function SetOwnerLighting()
{
	if ( (Pawn(Owner) != None) && Pawn(Owner).IsPlayerPawn()
		&& (Pawn(Owner).PlayerReplicationInfo.HasFlag != None) ) 
		return;
	Owner.AmbientGlow = 254; 
	Owner.LightEffect=LE_NonIncidence;
	Owner.LightBrightness=255;
	Owner.LightHue=210;
	Owner.LightRadius=10;
	Owner.LightSaturation=0;
	Owner.LightType=LT_Steady;
	Owner.bDynamicLight = true;
}

function SetUDamageWeapon()
{
	if ( !bActive )
		return;

	SetOwnerLighting();

	// Make old weapon normal again.
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		UDamageWeapon.Affector = None;
	}
		
	UDamageWeapon = Pawn(Owner).Weapon;
	// Make new weapon cool.
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.Affector = self;
		if ( Level.DetailMode != DM_Low )
			UDamageWeapon.SetDisplayProperties(ERenderStyle.STY_Translucent, 
									 FireTexture'WarEffects.Belt_fx.UDamageFX',
									 true);
		else
			UDamageWeapon.SetDisplayProperties(ERenderStyle.STY_Normal, 
							 FireTexture'WarEffects.Belt_fx.UDamageFX',
							 true);
	}
}

//
// Player has activated the item, pump up their damage.
//
state Activated
{
	function Timer()
	{
		if ( FinalCount > 0 )
		{
			SetTimer(1.0, true);
			Owner.PlaySound(DeActivateSound,, 8);
			FinalCount--;
			return;
		}
		UsedUp();
	}

	function SetOwnerDisplay()
	{
		if( Inventory != None )
			Inventory.SetOwnerDisplay();

		SetUDamageWeapon();
	}

	function OwnerEvent(name EventName)
	{
		if( Inventory != None )
			Inventory.OwnerEvent(EventName);

		if ( EventName == 'ChangedWeapon' )
			SetUDamageWeapon();
	}

	function EndState()
	{
		UsedUp();
	}

	function BeginState()
	{
		bActive = true;
		FinalCount = Min(FinalCount, 0.1 * Charge - 1);
		SetTimer(0.1 * Charge - FinalCount,false);
		Owner.PlaySound(ActivateSound);	
		SetOwnerLighting();
		Pawn(Owner).DamageScaling = 3.0;
		SetUDamageWeapon();	
	}
}

defaultproperties
{
	ExtraFireSound=Sound'Pickups.AmpFire'
	EndFireSound=Sound'Pickups.AmpFire2b'
	FinalCount=5
	bAutoActivate=true
	bActivatable=true
	DeActivateSound=Sound'Pickups.AmpOut'
	bDisplayableInv=true
	PickupClass=Class'UDamage'
	Charge=300
	Icon=Texture'Icons.I_UDamage'
	MessageClass=Class'WarfareGame.ItemMessagePlus'
}