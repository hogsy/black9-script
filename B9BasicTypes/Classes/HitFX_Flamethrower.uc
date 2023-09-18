//=============================================================================
// HitFX_Flamethrower.uc
//
// FX played when an actor is hit by the flamethrower
//
// 
//=============================================================================


class HitFX_Flamethrower extends Effects;


//////////////////////////////////
// Variables
//
var Emitter		fEmitter;


//////////////////////////////////
// Functions
//

simulated function PostBeginPlay()
{
	SetBase( Owner );

	fEmitter = Spawn( class'HitFX_Flamethrower_Emitter', Self,, Location, Rotation );
	fEmitter.SetBase( Self );
}

simulated function Tick( float Delta )
{
	if( Owner == None )
	{
		Destroy();
	}
}

simulated event Destroyed()
{
	if( fEmitter != None )
	{
		fEmitter.Destroy();
		fEmitter = None;
	}
}



//////////////////////////////////
// Initialization
//


defaultproperties
{
	EffectSound1=Sound'WarfareAmbient.Fire.fire_burn03'
	DrawType=0
	LifeSpan=5
}