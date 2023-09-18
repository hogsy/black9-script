//=============================================================================
// GrapplingHookAmmunition
//
// This is an interesting class because the Grappling Hook doesnt really
// require ammunition but this class is need to compile the weapon code
// 
//=============================================================================

class GrapplingHookAmmunition extends Ammunition;

var GrapplingHookProjectile fHook;

simulated function bool HasAmmo()
{
	return true;
}

function SpawnProjectile(vector Start, rotator Dir)
{
	if ( fHook != None )
	{
		fHook.ReleaseHook();
	}

	fHook = GrapplingHookProjectile( Spawn(ProjectileClass,Owner,, Start,Dir) );	
}

defaultproperties
{
	MaxAmmo=1
	AmmoAmount=1
	ProjectileClass=Class'GrapplingHookProjectile'
	RefireRate=1.5
	ItemName="Grappling Hook"
}