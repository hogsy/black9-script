class ExplosionParticles extends Emitter;

simulated function PostBeginPlay()
{
	MakeSound();
	if ( Level.bDropDetail )
		LightRadius = 6;

	// Set location (explosion)
	Emitters[0].StartLocationOffset += Location;
	Emitters[1].StartLocationOffset += Location;
	Emitters[2].StartLocationOffset += Location;
	Emitters[3].StartLocationOffset += Location;

	// Set location (wood chips)
	Emitters[4].StartLocationOffset += Location;
	Emitters[5].StartLocationOffset += Location;
		
	// Auto destroy emitter
	AutoDestroy=true;
		
	LifeSpan = 2.0;
	Super.PostBeginPlay();		
}

function MakeSound()
{
	PlaySound(Sound'Explo1',,12.0,,120);
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	LightType=8
	LightEffect=13
	LightBrightness=192
	LightRadius=9
	LightHue=27
	LightSaturation=71
	bNoDelete=false
	bDynamicLight=true
}