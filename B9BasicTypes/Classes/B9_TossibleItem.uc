class B9_TossibleItem extends B9_AccumulativeItem;

var vector	fFireOffset;
var	name	fFiringMode;			// replicated to identify what type of firing/reload animations to play
var float	fAimError;



function Activate()
{
	if( bActivatable )
	{
		Log("Activate "$self);

/*		if (Level.Game.StatLog != None)
			Level.Game.StatLog.LogItemActivate(Self, Pawn(Owner));*/

		B9_AdvancedPawn(Owner).PlayThrowOverhand();
		//Fire( 0 );
	}
}

simulated function Fire( float Value )
{
	if ( !HasItems() )
	{
		return;
	}

	ServerFire();
	if ( Role < ROLE_Authority )
	{
		LocalFire();
	}
}
	
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
	local Pawn		P;
	local coords	C;
	local vector	V;
	
	P = Pawn( Owner );
	C = P.GetBoneCoords( 'NanoBone' );
	V = C.Origin;

	return (V + fFireOffset.X * X + fFireOffset.Y * Y + fFireOffset.Z * Z); 
}

function SpawnProjectile(vector Start, rotator Dir)
{
	local Pawn Instigator;

	Instigator = Pawn(Owner);

	if ( Amount > 0 )
	{
		Amount -= 1;
		Spawn(ProjectileClass,,, Start,Dir);	
	}

	if ( Amount <= 0 && Instigator != None )
	{
		Instigator.DeleteInventory(self);
	}
}

function ProjectileFire()
{
	local Vector Start, X,Y,Z;
	local rotator AdjustedAim;
	local Pawn Instigator;

	Instigator = Pawn(Owner);

	Instigator.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	Start = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(None, Start, fAimError);	
	SpawnProjectile(Start,AdjustedAim);	
}

function ServerFire()
{
	if ( HasItems() )
	{
		ProjectileFire();
		LocalFire();
	}
}

simulated function LocalFire()
{
	local Pawn Instigator;

	Instigator = Pawn(Owner);

	if ( Instigator != None )
	{
		Instigator.PlayFiring( 1.0, fFiringMode );
	}
}		

//=============================================================================
// Active state: this inventory item is armed and ready to rock!

state Activated
{
	function Activate()
	{
		Fire(0);
		Super.Activate();
	}
}

defaultproperties
{
	fFiringMode=MODE_Overhand
	fAimError=800
	MaxAmount=200
	Amount=50
	PickupAmount=50
	MyDamageType=Class'damage_Explosive_Gren_Frag'
	bActivatable=true
}