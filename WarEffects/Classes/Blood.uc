// Blood
//this effect is an animated smoke puff.  It also spawns a particle emitter
//
class Blood extends UT_SpriteSmokePuff;

#exec OBJ LOAD FILE=..\botpack\textures\BloodyPuff.utx PACKAGE=WarEffects.BloodyPuff

simulated function PostNetBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
		SpawnEmitter();
}

simulated function SpawnEmitter()
{
	local emitter e;

	e = Spawn(class'BloodBurst');
//	e.StartVelocityRange = 120 * vector(Rotation);
}

defaultproperties
{
	SSprites[0]=Texture'BloodyPuff.bp_A01'
	SSprites[1]=Texture'BloodyPuff.bp8_a00'
	SSprites[2]=Texture'BloodyPuff.Bp6_a00'
	SSprites[3]=none
	RisingRate=-50
	NumSets=3
	bHighDetail=true
	LifeSpan=0.5
	Texture=Texture'BloodyPuff.bp_A01'
}