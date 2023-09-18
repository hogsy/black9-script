//=============================================================================
// UTTeleportEffect.
//=============================================================================
class UTTeleportEffect extends Effects;

#exec MESH IMPORT MESH=UTTeleEffect ANIVFILE=..\botpack\MODELS\tele2_a.3D DATAFILE=..\botpack\MODELS\tele2_d.3D
#exec MESH ORIGIN MESH=UTTeleEffect X=0 Y=0 Z=-200 YAW=64
#exec MESH SEQUENCE MESH=UTTeleEffect SEQ=All  STARTFRAME=0  NUMFRAMES=30
#exec MESH SEQUENCE MESH=UTTeleEffect  SEQ=Burst  STARTFRAME=0  NUMFRAMES=30
#exec MESHMAP SCALE MESHMAP=UTTeleEffect X=0.06 Y=0.06 Z=0.16
 
#exec OBJ LOAD FILE=..\botpack\textures\FlareFX.utx PACKAGE=WarEffects.FlareFX

var bool bSpawnEffects;
var UTTeleEffect T1, T2;


function Initialize(pawn Other, bool bOut)
{

}

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		local rotator newrot;

		if ( Level.DetailMode == DM_Low )
		{
			bOwnerNoSee = true;
			Disable('Tick');
			return;
		}

		if ( Level.NetMode == NM_DedicatedServer )
		{
			Disable('Tick');
			return;
		}

		LightBrightness = (Lifespan/Default.Lifespan)*210.0;

		if ( Level.DetailMode == DM_Low )
		{
			LightRadius = 6;
			return;
		}

		if ( !bSpawnEffects )
		{
			bSpawnEffects = true;
			T1 = spawn(class'UTTeleeffect');
			newrot = Rotation;
			newRot.Yaw = 2 * Rand(32767);
			T2 = spawn(class'UTTeleeffect',,,location - vect(0,0,10), newRot);
		}
		else
		{
		}
	}

	simulated function BeginState()
	{
		PlayAnim('All',0.6);
	}
}

defaultproperties
{
	LightType=2
	LightEffect=13
	LightBrightness=255
	LightRadius=9
	LightHue=170
	LightSaturation=96
	DrawType=2
	bDynamicLight=true
	LifeSpan=1
	Mesh=VertMesh'UTTeleEffect'
	Texture=Texture'FlareFX.utflare1'
	DrawScale=0.2
	Skins=/* Array type was not detected. */
	Style=3
}