class WeaponTurret extends Pawn
	abstract;

var (WeaponTurret)	rotator		DesiredRot; // Direction you _want_ turret to point in.

var					Pawn		Gunner;

event FireTurret(); // Called by PlayerController when gunning Pawn hits fire


// The actor Other has tried to take control of this vehicle
function TryToGun(Pawn p)
{
	local Controller C;
	C = p.Controller;

    if ( (Gunner == None) && (C != None) && C.bIsPlayer && !C.IsInState('PlayerGunning') && p.IsHumanControlled())
	{        
		KGunnerEnter(p);
    }
}

event KGunnerEnter( Pawn p )
{

}

event KGunnerLeave()
{

}


