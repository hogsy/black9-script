//#exec OBJ LOAD FILE=..\staticmeshes\EffectMeshes.usx
//#exec OBJ LOAD FILE=..\textures\VehicleFX.utx

class BulldogDust extends Emitter;

var () int		MaxSpritePPS;
var () int		MaxMeshPPS;

simulated function UpdateDust(KTire t, float DustSlipRate, float DustSlipThresh)
{
	local float SpritePPS, MeshPPS;

	//Log("Material:"$t.GroundMaterial$" OnGround:"$t.bTireOnGround);

	// If wheel is on ground, and slipping above threshold..
	if(t.bTireOnGround && t.GroundSlipVel > DustSlipThresh)
	{
		SpritePPS = FMin(DustSlipRate * (t.GroundSlipVel - DustSlipThresh), MaxSpritePPS);

		Emitters[0].ParticlesPerSecond = SpritePPS;
		Emitters[0].InitialParticlesPerSecond = SpritePPS;
		Emitters[0].AllParticlesDead = false;

		MeshPPS = FMin(DustSlipRate * (t.GroundSlipVel - DustSlipThresh), MaxMeshPPS);

		Emitters[1].ParticlesPerSecond = MeshPPS;
		Emitters[1].InitialParticlesPerSecond = MeshPPS;
		Emitters[1].AllParticlesDead = false;		
	}
	else // ..otherwise, switch off.
	{
		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;

		Emitters[1].ParticlesPerSecond = 0;
		Emitters[1].InitialParticlesPerSecond = 0;
	}
}

defaultproperties
{
	MaxSpritePPS=35
	MaxMeshPPS=35
	Emitters=/* Array type was not detected. */
	bNoDelete=false
	bHardAttach=true
}