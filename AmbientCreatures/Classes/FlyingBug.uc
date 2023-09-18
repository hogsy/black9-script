/*=============================================================================

 //FlyingBug
=============================================================================*/

class FlyingBug extends Bug;

#exec MESH  MODELIMPORT MESH=WaspMesh MODELFILE=Models\Wasp.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=WaspMesh X=0 Y=0 Z=0 YAW=192 PITCH=00 ROLL=0
#exec ANIM  IMPORT ANIM=WaspAnims ANIMFILE=Models\Wasp.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=WaspMesh X=0.4 Y=0.4 Z=0.4
#exec ANIM  SEQUENCE ANIM=WaspAnims SEQ=fly STARTFRAME=0 NUMFRAMES=2 RATE=30.0000 COMPRESS=1 GROUP=None 
#exec MESH  DEFAULTANIM MESH=WaspMesh ANIM=WaspAnims

// Digest and compress the animation data. Must come after the sequence declarations.
// 'VERBOSE' gives more debugging info in UCC.log 
#exec ANIM DIGEST  ANIM=WaspAnims VERBOSE

#EXEC TEXTURE IMPORT NAME=WaspTex1 FILE=models\Wasp.dds GROUP=Skins
#EXEC TEXTURE IMPORT NAME=WaspTex2 FILE=models\Wasp2.dds GROUP=Skins
#EXEC MESHMAP SETTEXTURE MESHMAP=WaspMesh NUM=0 TEXTURE=WaspTex1

#exec AUDIO IMPORT FILE="Sounds\buzz3.WAV" NAME="flybuzz" GROUP="Flies"

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Fly');
	if ( FRand() < 0.5 )
		Skins[0] = texture'AmbientCreatures.WaspTex2';
}


			
defaultproperties
{
	LandMovementState=PlayerFlying
	AmbientSound=Sound'Flies.flybuzz'
	Mesh=SkeletalMesh'WaspMesh'
	SoundRadius=2
	SoundVolume=128
}