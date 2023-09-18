class Invisibility extends Powerups;


state Activated
{
	function endstate()
	{
		bActive = false;		
		PlaySound(DeActivateSound);
		Owner.SetDefaultDisplayProperties();
	}

	function Activate()
	{
		bActive = true;
		SetOwnerDisplay();
	}

	function SetOwnerDisplay()
	{
		if ( !bActive )
			return;
		Owner.SetDisplayProperties(ERenderStyle.STY_Translucent, 
							 FireTexture'WarEffects.Belt_fx.Invis',
							 true);
		if( Inventory != None )
			Inventory.SetOwnerDisplay();
	}

	function OwnerEvent(name EventName)
	{
		if ( !bActive )
			return;
		if( Inventory != None )
			Inventory.OwnerEvent(EventName);

		if ( EventName == 'ChangedWeapon' )
		{
			// Make new weapon invisible.
			if ( Pawn(Owner).Weapon != None )
				Pawn(Owner).Weapon.SetDisplayProperties(ERenderStyle.STY_Translucent, 
										 FireTexture'WarEffects.Belt_fx.Invis',
										 true);
		}
	}

	function Timer()
	{
		Charge -= 1;
		Pawn(Owner).Visibility = 10;
		if (Charge<-0)
			UsedUp();
	}

	function BeginState()
	{
		bActive = true;
		PlaySound(ActivateSound,,4.0);

		Owner.SetDisplayProperties(ERenderStyle.STY_Translucent, 
								   FireTexture'WarEffects.Belt_fx.Invis',
								   false);
		SetTimer(0.5,True);
	}
}

state DeActivated
{
Begin:
}

defaultproperties
{
	bAutoActivate=true
	bActivatable=true
	ExpireMessage="Invisibility has worn off."
	ActivateSound=Sound'Pickups.Invisible'
	bDisplayableInv=true
	Charge=100
	ItemName="Invisibility"
	MessageClass=Class'WarfareGame.ItemMessagePlus'
}