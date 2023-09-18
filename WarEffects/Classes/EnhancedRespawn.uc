//=============================================================================
// EnhancedRespawn.
//=============================================================================
class EnhancedRespawn extends Effects;

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\item-respawn2.WAV" NAME="RespawnSound2" GROUP="Generic"

#exec MESH IMPORT MESH=TeleEffect2 ANIVFILE=..\botpack\MODELS\telepo_a.3D DATAFILE=..\botpack\MODELS\telepo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TeleEffect2 X=0 Y=0 Z=-200 YAW=0
#exec MESH SEQUENCE MESH=TeleEffect2 SEQ=All  STARTFRAME=0  NUMFRAMES=30
#exec MESH SEQUENCE MESH=TeleEffect2  SEQ=Burst  STARTFRAME=0  NUMFRAMES=30
#exec MESHMAP SCALE MESHMAP=TeleEffect2 X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=TeleEffect2 NUM=0 TEXTURE=DefaultTexture

simulated function BeginPlay()
{
	Super.BeginPlay();
	Playsound(sound'RespawnSound2');
	PlayAnim('All',0.8);
}

simulated function PostBeginPlay()
{
	local Pickup P;

	Super.PostBeginPlay();
	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
	Playsound(sound'RespawnSound2');
	if ( Owner != None )
	{
		P = Pickup(Owner);
 		if ( P != None )
		{
			LinkMesh(P.Mesh);
			if ( P.RespawnTime < 15 )
				LifeSpan = 0.5;
		}
		else
			LinkMesh(Owner.Mesh);
	}
}

auto state Explode
{
	simulated function Tick( float DeltaTime )
	{
		if ( Owner != None )
		{
			if ( Owner.LatentFloat > 1 ) //got picked up and put back to sleep
			{
				Destroy();
				Return;
			} 
			SetRotation(Owner.Rotation);
		}
		if ( Level.bDropDetail )
			LifeSpan -= DeltaTime;
		LightBrightness = (Lifespan/Default.Lifespan)*210.0;
		SetDrawScale(0.03 + 0.77 * (Lifespan/Default.Lifespan));
	}

	simulated function AnimEnd( int Channel )
	{
		RemoteRole = ROLE_None;
		Destroy();
	}
}

defaultproperties
{
	LightType=1
	LightEffect=13
	LightBrightness=210
	LightRadius=6
	LightHue=30
	LightSaturation=224
	DrawType=2
	bDynamicLight=true
	LifeSpan=1.5
	Mesh=VertMesh'TeleEffect2'
	Texture=Texture'DBEffect.de_A00'
	DrawScale=1.1
	Skins=/* Array type was not detected. */
	AmbientGlow=255
	Style=3
}