//=============================================================================
// ExplosionFX_One.uc
//
// BOOOOOM! WIth lingering smoke
//
// 
//=============================================================================


class ExplosionFX_One extends Effects;


//////////////////////////////////
// Variables
//
var private Emitter		fEmitter;
var private ViewShaker	fShaker;
var private float		fTimer;
var private bool		fSmoking;

//////////////////////////////////
// Functions
//

simulated function PostBeginPlay()
{
	SetBase( Owner );

	fEmitter	= Spawn( class'ExplosionFX_One_Emitter', Self,, Location, Rotation );
	fShaker		= Spawn( class'ViewShaker', Self,, Location, Rotation );

	fShaker.ShakeRadius				= 2000.0;
	fShaker.OffsetMagVertical		= 30;
	fShaker.OffsetRateVertical		= 1000;
	fShaker.OffsetMagHorizontal		= 30;
	fShaker.OffsetRateHorizontal	= 1000;
	fShaker.OffsetIterations		= 30.0;
	
	fShaker.Trigger( None, None );
}


simulated function Tick( float Delta )
{
	if( !fSmoking )
	{
		fTimer += Delta;
		if( fTimer >= 0.15 )
		{
			fTimer		= 0.0;
			fSmoking	= true;

			fEmitter.Emitters[1].disabled = false;
			fEmitter.Emitters[2].disabled = false;
		}
	}
}

simulated event Destroyed()
{
	if( fEmitter != None )
	{
		fEmitter.Destroy();
		fEmitter = None;
	}
	if( fShaker != None )
	{
		fShaker.Destroy();
		fShaker = None;
	}
}



//////////////////////////////////
// Initialization
//











defaultproperties
{
	EffectSound1=Sound'B9Weapons_sounds.explosives.grenade_explo1'
	DrawType=0
	LifeSpan=4.5
}