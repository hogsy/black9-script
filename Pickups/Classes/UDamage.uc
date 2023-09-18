//=============================================================================
// UDamage.
//=============================================================================
class UDamage extends WarfarePickup;

#exec TEXTURE IMPORT NAME=I_UDamage FILE=..\botpack\TEXTURES\HUD\i_udamage.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=GoldSkin2 FILE=..\botpack\models\gold.PCX GROUP="None"

#exec MESH IMPORT MESH=udamage ANIVFILE=..\botpack\MODELS\udamage_a.3d DATAFILE=..\botpack\MODELS\udamage_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=udamage STRENGTH=0.6
#exec MESH SEQUENCE MESH=udamage SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=udamage SEQ=Udamage STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=udamage MESH=udamage
#exec MESHMAP SCALE MESHMAP=udamage X=0.05 Y=0.05 Z=0.1

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\MofSFire.WAV" NAME="AmpFire" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\MofSPickup.WAV" NAME="AmpPickup" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\MofSFO1.WAV" NAME="AmpOut" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\MofSRunOut1b.WAV" NAME="AmpFire2b" GROUP="Pickups"

defaultproperties
{
	MaxDesireability=2.5
	InventoryType=Class'UDamageInv'
	RespawnTime=120
	PickupMessage="You got the Damage Amplifier!"
	PickupSound=Sound'Pickups.AmpPickup'
	Physics=5
	Mesh=VertMesh'UDamage'
	Texture=Texture'GoldSkin2'
}