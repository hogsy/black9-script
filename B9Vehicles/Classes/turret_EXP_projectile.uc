

class turret_EXP_projectile extends projectile;


var	fx_turretEXP_proj_trail fTrail;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

//	SetTimer(0.8, true);

	if ( Level.NetMode == NM_Client )
	{
		LifeSpan = 5.0;
	}
	else
	{
		Velocity = Speed * vector(Rotation);
	}

	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
}

simulated function PostNetBeginPlay()
{

	if ( fTrail == None )
	{
		fTrail = Spawn(class'fx_turretEXP_proj_trail', self);
	}
	SetTimer(0.1, false);
}


simulated function Destroyed()
{
	if( fTrail != None )
	{
		fTrail.Destroy();
	}
	
	Super.Destroyed();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Super.HitWall( HitNormal, Wall );
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp( HitLocation );
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(ExplosionDecal,,,,rot(16384,0,0));
  		spawn(class'ExplosionFX_One_Emitter',,,HitLocation,rot(16384,0,0));
	}
 	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local B9WeaponBase B9W;
	local float dmg, excessdist;

	If ( Other != Instigator )
	{
		if ( Role == ROLE_Authority )
		{
			Other.TakeDamage( dmg, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);	
		}
		
		Explode(HitLocation, vect(0,0,1));
	}
}

defaultproperties
{
	Speed=5000
	MaxSpeed=5000
	Damage=75
	MomentumTransfer=10000
	LifeSpan=10
	Mesh=SkeletalMesh'B9Weapons_models.SG_rocket'
	DrawScale=3
	SoundRadius=2
	SoundVolume=75
	CollisionRadius=22
	CollisionHeight=11
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.6
}