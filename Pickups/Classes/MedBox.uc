//=============================================================================
// MedBox.
//=============================================================================
class MedBox extends TournamentHealth;

#exec MESH IMPORT MESH=MedBox ANIVFILE=..\botpack\MODELS\MedBox_a.3d DATAFILE=..\botpack\MODELS\MedBox_d.3d LODSTYLE=10
#exec MESH ORIGIN MESH=MedBox X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=MedBox SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=MedBox SEQ=MEDBOX STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JMedBox1 FILE=..\botpack\Textures\MedBox.PCX GROUP=Skins LODSET=2
#exec MESHMAP NEW   MESHMAP=MedBox MESH=MedBox
#exec MESHMAP SCALE MESHMAP=MedBox X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=MedBox NUM=1 TEXTURE=JMedBox1 TLOD=30
#exec OBJ LOAD FILE=..\botpack\Textures\ShaneFx.utx  PACKAGE=Pickups.ShaneFx
#exec MESHMAP SETTEXTURE MESHMAP=MedBox NUM=2 TEXTURE=Pickups.ShaneFx.top3

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\healthReg.WAV" NAME="UTHealth" GROUP="Pickups"

defaultproperties
{
	PickupSound=Sound'Pickups.UTHealth'
	Mesh=VertMesh'MedBox'
	CollisionRadius=32
}