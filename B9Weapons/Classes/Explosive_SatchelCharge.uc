class Explosive_SatchelCharge extends B9_TossibleItem;

var private B9Explosive_Proj	fDeployedCharge;


function Activate()
{
	if( bActivatable )
	{
/*		if (Level.Game.StatLog != None)
			Level.Game.StatLog.LogItemActivate(Self, Pawn(Owner));*/

		B9_AdvancedPawn(Owner).PlayThrowOverhand();

		GotoState( 'Activated' );
		//Activate();
	}
}

function SpawnProjectile(vector Start, rotator Dir)
{
	local Pawn Instigator;

	Instigator = Pawn(Owner);

	if ( Amount > 0 )
	{
		fDeployedCharge = B9Explosive_Proj( Spawn(ProjectileClass,,, Start,Dir) );	
	}
}

function UpdateAmmoCount()
{
	if( Amount > 0 )
	{
		Amount -= 1;
	}

	if ( Amount <= 0 && Instigator != None )
	{
		Instigator.DeleteInventory(self);
	}
}



state Activated
{
	function BeginState()
	{
		if( fDeployedCharge != none )
		{
			GotoState( 'Deployed' );
		}
	}

	simulated function Fire( float Value )
	{
		Super.Fire( Value );
		GotoState( 'Deployed' );
	}

	//function Activate()
	//{
	//	Fire(0);
	//	GotoState( 'Deployed' );
	//}
}

state Deployed
{
	function Activate()
	{
		if( fDeployedCharge != none )
		{
			fDeployedCharge.Detonate();
			fDeployedCharge.Destroy();
			fDeployedCharge = none;
			GotoState( 'Activated' );
		}
	}
}







defaultproperties
{
	Amount=1
	PickupAmount=1
	ProjectileClass=Class'Explosive_SatchelCharge_Proj'
	fUniqueID=8
	Icon=Texture'B9HUD_textures.Browser_items.gen_kit_bricon'
	ItemName="Satchel Charge"
}