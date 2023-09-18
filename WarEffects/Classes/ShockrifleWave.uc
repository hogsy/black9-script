//=============================================================================
// ShockrifleWave.
//=============================================================================
class ShockrifleWave extends Effects;

#exec MESH IMPORT MESH=ShockRWM ANIVFILE=..\botpack\MODELS\SW_a.3D DATAFILE=..\botpack\MODELS\SW_d.3D X=0 Y=0 Z=0 
#exec MESH ORIGIN MESH=ShockRWM X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=ShockRWM SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=ShockRWM SEQ=Explosion STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=ShockRWM SEQ=Implode   STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=ShocktT1 FILE=..\botpack\MODELS\shockw2.PCX  GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=ShockRWM X=1.0 Y=1.0 Z=2.0 
#exec MESHMAP SETTEXTURE MESHMAP=ShockRWM NUM=1 TEXTURE=ShocktT1

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if ( Level.DetailMode == DM_Low || Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
}

simulated function Tick( float DeltaTime )
{
	local float ShockSize;

	ShockSize = 0.7/((Lifespan/Default.Lifespan)+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		AmbientGlow = (Lifespan/Default.Lifespan) * 255;
		SetDrawScale(ShockSize);
	}
}

defaultproperties
{
	LightType=1
	LightEffect=13
	LightBrightness=255
	LightRadius=6
	LightHue=195
	DrawType=2
	bDynamicLight=true
	RemoteRole=2
	LifeSpan=1.3
	Mesh=VertMesh'ShockRWM'
	AmbientGlow=255
	Style=3
}