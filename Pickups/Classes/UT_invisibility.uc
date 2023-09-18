//=============================================================================
// UT_Invisibility.
//=============================================================================
class UT_Invisibility extends WarfarePickUp;


#exec MESH IMPORT MESH=invis2M ANIVFILE=..\botpack\MODELS\invis_a.3D DATAFILE=..\botpack\MODELS\invis_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=invis2M STRENGTH=0.5
#exec MESH ORIGIN MESH=invis2M X=0 Y=0 Z=0  YAW=0
#exec MESH SEQUENCE MESH=invis2M SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jinvis FILE=..\botpack\MODELS\invis2.pcx GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=invis2M X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=invis2M NUM=1 TEXTURE=jinvis

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\Scloak1.WAV" NAME="Invisible" GROUP="Pickups"

defaultproperties
{
	MaxDesireability=1.2
	InventoryType=Class'Invisibility'
	RespawnTime=120
	PickupMessage="You have Invisibility."
	PickupSound=Sound'WarEffects.Pickups.GenPickSnd'
	Mesh=VertMesh'invis2M'
	Texture=FireTexture'WarEffects.Belt_fx.Invis.Invis'
	CollisionRadius=15
	CollisionHeight=20
}