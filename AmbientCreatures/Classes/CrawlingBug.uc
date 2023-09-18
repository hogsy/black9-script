class CrawlingBug extends Bug;

#exec MESH IMPORT MESH=Firefly ANIVFILE=MODELS\firefl_a.3D DATAFILE=MODELS\firefl_d.3D  LODSTYLE=2
#exec MESH LODPARAMS MESH=FireFly STRENGTH=0.6 
#exec MESH ORIGIN MESH=Firefly X=0 Y=00 Z=0 YAW=64

#exec MESH SEQUENCE MESH=Firefly SEQ=All    STARTFRAME=0   NUMFRAMES=5
#exec MESH SEQUENCE MESH=Firefly SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Firefly SEQ=Moving STARTFRAME=0   NUMFRAMES=4
#exec MESH SEQUENCE MESH=Firefly SEQ=FastFly  STARTFRAME=4   NUMFRAMES=2

#exec TEXTURE IMPORT NAME=JFirefly1 FILE=MODELS\firefly.PCX GROUP=Skins MASKED=1
#exec MESHMAP SCALE MESHMAP=Firefly X=0.006 Y=0.006 Z=0.012
#exec MESHMAP SETTEXTURE MESHMAP=firefly NUM=1 TEXTURE=Jfirefly1

defaultproperties
{
	bFlyer=false
	bCrawler=true
	AirSpeed=170
	AccelRate=1500
	Mesh=VertMesh'Firefly'
	RotationRate=(Pitch=4096,Yaw=120000,Roll=0)
}