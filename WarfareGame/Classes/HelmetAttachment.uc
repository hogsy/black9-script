class HelmetAttachment extends InventoryAttachment;

event TornOff()
{
	Velocity = vect(0,0,150) + 150 * VRand();
	if ( Base != None )
	{
		Velocity = 1.2 * Base.Velocity + Velocity;
		if( bUseLightingFromBase )
		{
			bUnlit = Base.bUnlit;
			AmbientGlow = Base.AmbientGlow;
		}
	}
	LifeSpan = 10;
	// FIXME - set location to bone location to be safe?
	SetBase(None);
	SetPhysics(PHYS_Falling); //FIXME Karma?
	bCollideWorld = true;
	SetCollision(true,false,false);
	bProjTarget = true;
	bHidden = false;
	LifeSpan = 10;
	RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	DesiredRotation = RotRand(true);
	bTearOff = true; 
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local float speed;
	
	Velocity = 0.8 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	Velocity.Z = FMin(Velocity.Z * 0.8, 700);
	speed = VSize(Velocity);
	if ( speed < 120 )
	{
		bBounce = false;
		Disable('HitWall');
	}
	// PlaySound(HitSounds[Rand(2)]); //FIXME need sound
	RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	DesiredRotation = RotRand(true);
}

simulated event Landed(vector HitNormal)
{
	// PlaySound(HitSounds[Rand(2)]); //FIXME need sound
	RotationRate = rot(65535,65535,65535);
	SetPhysics(PHYS_Rotating);
	bFixedRotationDir = false;
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
}

simulated event EndedRotation()
{
	if ( Physics == PHYS_Rotating )
		SetPhysics(PHYS_None);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if ( Base != None )
		return;
	SetPhysics(PHYS_Falling);
	bFixedRotationDir = true;
	RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	DesiredRotation = RotRand(true);
	Velocity = momentum + vect(0,0,100);
	LifeSpan = FMax(LifeSpan,6);
}

defaultproperties
{
	DrawType=8
	bOrientOnSlope=true
	RelativeLocation=(X=0,Y=-0.6,Z=0)
	DrawScale=0.75
	CollisionRadius=11
	CollisionHeight=11
	bBounce=true
	bFixedRotationDir=true
	bRotateToDesired=true
}