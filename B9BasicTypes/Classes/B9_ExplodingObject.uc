//=============================================================================
// B9_ExplodingObject.uc
//
// Shoot it and it goes boom!
//
//=============================================================================


class B9_ExplodingObject extends B9_Special_Level_Objects
		placeable;


var(ExplodingObject) class<Emitter>		ExplosionType;
var(ExplodingObject) class<Emitter>		SecondaryExplosionFX;
var(ExplodingObject) int				MyHealth;
var(ExplodingObject) int				DamageToCause;
var(ExplodingObject) float				MyDamageRadius;
var(ExplodingObject) name				ExplosionTriggers;
var(ExplodingObject) bool				bTakeDamage;


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation,
					 vector Momentum, class<DamageType> DamageType )
{
	if(bTakeDamage)
	{
		MyHealth -= Damage;
		if( MyHealth <= 0 )
		{
			Explode(EventInstigator);
		}
	}
}

function Trigger (Actor Other, Pawn EventInstigator)
{
	Explode(EventInstigator);
}

simulated function Explode(Pawn EventInstigator)
{
	if( ExplosionType != none )
	{
		Spawn( ExplosionType, , , Location );
	}

	if( SecondaryExplosionFX != none )
	{
		Spawn( SecondaryExplosionFX, , , Location );
	}

	HurtRadius( DamageToCause, MyDamageRadius, class'Impact', 0, Location );

	if(ExplosionTriggers != '')
	{
		TriggerEvent(ExplosionTriggers, self, EventInstigator);
	}

	Destroy();
}



defaultproperties
{
	MyHealth=10
	DamageToCause=25
	MyDamageRadius=500
	bTakeDamage=true
	DrawType=8
	StaticMesh=StaticMesh'Editor.TexPropCube'
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
	bBlockPlayers=true
}