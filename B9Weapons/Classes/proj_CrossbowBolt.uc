//=============================================================================
// proj_CrossbowBolt.uc
//=============================================================================

class proj_CrossbowBolt extends B9ProjectileBase;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_Client )
	{
		LifeSpan = 5.0;
	}
	else
	{
		Velocity = Speed * vector(Rotation);
		OrientProjectile(Instigator);
	}

	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local B9WeaponBase B9W;

	If ( Other != Instigator )
	{
		if ( Role == ROLE_Authority )
		{
			Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);	
		}
		
		Explode(HitLocation, vect(0,0,1));
	}
}

defaultproperties
{
	fIniLookupName="Crossbow"
	Speed=1024
	Damage=10
	DamageRadius=1
	MomentumTransfer=10000
	MyDamageType=Class'B9BasicTypes.damage_CrossbowBolt'
	LifeSpan=10
	Mesh=SkeletalMesh'B9Weapons_models.Proj_CrossbowBolt_mesh'
	SoundRadius=2
	SoundVolume=75
	CollisionRadius=22
	CollisionHeight=11
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.6
}