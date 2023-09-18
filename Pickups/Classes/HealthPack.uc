class HealthPack extends TournamentHealth;

#exec MESH IMPORT MESH=hbox ANIVFILE=..\botpack\MODELS\Superhealth_a.3d DATAFILE=..\botpack\MODELS\Superhealth_d.3d LODSTYLE=10
#exec MESH LODPARAMS MESH=hbox STRENGTH=0.5
#exec MESH ORIGIN MESH=hbox X=0 Y=0 Z=0 PITCH=0 ROLL=-64
#exec MESH SEQUENCE MESH=hbox SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=hbox SEQ=HBOX STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jhbox1 FILE=..\botpack\MODELS\Superhealth.PCX GROUP=Skins LODSET=2
#exec MESHMAP NEW   MESHMAP=hbox MESH=hbox
#exec MESHMAP SCALE MESHMAP=hbox X=0.08 Y=0.08 Z=0.16
#exec OBJ LOAD FILE=..\botpack\Textures\ShaneFx.utx  PACKAGE=Pickups.ShaneFx
#exec MESHMAP SETTEXTURE MESHMAP=hbox NUM=1 TEXTURE=Jhbox1
#exec MESHMAP SETTEXTURE MESHMAP=hbox NUM=2 TEXTURE=Pickups.ShaneFx.top3

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\healthSuper.WAV" NAME="UTSuperHeal" GROUP="Pickups"

defaultproperties
{
	HealingAmount=100
	bSuperHeal=true
	MaxDesireability=2
	RespawnTime=100
	PickupMessage="You picked up the Big Keg O' Health +"
	PickupSound=Sound'Pickups.UTSuperHeal'
	Mesh=VertMesh'hbox'
	DrawScale=0.8
	CollisionRadius=26
	CollisionHeight=19.5
}