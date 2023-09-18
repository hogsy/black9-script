// ====================================================================
//  Class:  WarClassLight.PclCOGP9Secondary
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class PclCOGP9Secondary extends Emitter;

function Activate(float Dist, int team)
{

	local float vel, Life;
	
	Life = SpriteEmitter(Emitters[2]).LifetimeRange.Min;
	vel = Dist * Life * -10;
	
	SpriteEmitter(Emitters[2]).StartVelocityRange.X.Min=vel;  
	SpriteEmitter(Emitters[2]).StartVelocityRange.X.Max=vel;
	SpriteEmitter(Emitters[3]).StartVelocityRange.X.Min=vel;
	SpriteEmitter(Emitters[3]).StartVelocityRange.X.Max=vel;

	Emitters[Team].Disabled=false;
	Emitters[Team+2].Disabled=false;
	Emitters[Team+4].Disabled=false;

}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	bNoDelete=false
	bDynamicLight=true
	RemoteRole=1
}