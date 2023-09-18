//=============================================================================
// Pammo.
//=============================================================================
class PAmmo extends TournamentAmmo;

#exec MESH IMPORT MESH=Pammo ANIVFILE=..\WarClassContent\MODELS\Pammo_a.3d DATAFILE=..\WarClassContent\MODELS\Pammo_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pammo X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=Pammo SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Pammo SEQ=all                      STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=Pammo MESH=Pammo
#exec MESHMAP SCALE MESHMAP=Pammo X=0.03 Y=0.03 Z=0.06
#exec TEXTURE IMPORT NAME=JPammo_01 FILE=..\WarClassContent\MODELS\PAmmo.PCX GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=Pammo NUM=1 TEXTURE=JPammo_01

defaultproperties
{
	AmmoAmount=25
	InventoryType=Class'PulseAmmo'
	PickupMessage="You picked up a Pulse Cell."
	Mesh=VertMesh'PAmmo'
	CollisionHeight=10
}