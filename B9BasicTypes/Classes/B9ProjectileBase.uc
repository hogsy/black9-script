//
// B9ProjectileBase
//

class B9ProjectileBase extends Projectile
	native;


var float		fDamageFalloff; 
var	float		fRandomSpin;	

var string	fIniLookupName;

native(2022) final function		InitIniStats();


simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	InitIniStats();
}

function OrientProjectile(Actor relativeTo)
{
	/*
	local rotator rot;

	if (fRandomSpin == 0.0f)
	{
		rot.Yaw = 48400.0f;
		SetRotation(relativeTo.Rotation + rot);
	}
	else
	{
		RandSpin(fRandomSpin);
	}
	*/
}

defaultproperties
{
	fRandomSpin=0.03
	LifeSpan=0
}