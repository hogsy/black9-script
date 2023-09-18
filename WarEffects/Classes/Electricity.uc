//=============================================================================
// Electricity.
//=============================================================================
class Electricity extends Effects;

#exec MESH IMPORT MESH=Electr ANIVFILE=..\botpack\MODELS\Electr_a.3D DATAFILE=..\botpack\MODELS\Electr_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Electr X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=Electr SEQ=All        STARTFRAME=0   NUMFRAMES=11
#exec MESH SEQUENCE MESH=Electr SEQ=ElectBurst STARTFRAME=0   NUMFRAMES=11
#exec OBJ LOAD FILE=..\botpack\Textures\fireeffect7.utx PACKAGE=WarEffects.Effect7
#exec MESHMAP SCALE MESHMAP=Electr X=0.15 Y=0.15 Z=0.3 YAW=128 
#exec MESHMAP SETTEXTURE MESHMAP=Electr NUM=1 TEXTURE=WarEffects.Effect7.MyTex16

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim( 'ElectBurst', 0.6 );
}

simulated function AnimEnd(int Channel)
{
	Destroy ();
}

defaultproperties
{
	LightType=1
	LightEffect=13
	LightBrightness=255
	LightRadius=3
	LightHue=200
	LightSaturation=255
	DrawType=2
	bDynamicLight=true
	LifeSpan=2
	Mesh=VertMesh'Electr'
}