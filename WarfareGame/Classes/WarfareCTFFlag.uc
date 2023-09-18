class WarfareCTFFlag extends CTFFlag;

#exec MESH IMPORT MESH=pflag ANIVFILE=..\botpack\MODELS\pflag_a.3d DATAFILE=..\botpack\MODELS\pflag_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=pflag X=400 Y=0 Z=0 YAW=128

#exec MESH SEQUENCE MESH=pflag SEQ=All   STARTFRAME=0 NUMFRAMES=133
#exec MESH SEQUENCE MESH=pflag SEQ=pflag STARTFRAME=0 NUMFRAMES=133

#exec TEXTURE IMPORT NAME=JpflagB FILE=..\botpack\MODELS\N-Flag-B.PCX GROUP=Skins MASKED=1 // twosided
#exec TEXTURE IMPORT NAME=JpflagR FILE=..\botpack\MODELS\N-Flag-R.PCX GROUP=Skins MASKED=1 // twosided

#exec MESHMAP NEW   MESHMAP=pflag MESH=pflag
#exec MESHMAP SCALE MESHMAP=pflag X=0.2 Y=0.2 Z=0.4

#exec MESHMAP SETTEXTURE MESHMAP=pflag NUM=0 TEXTURE=JpflagB

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('pflag');
}

defaultproperties
{
	Mesh=VertMesh'pflag'
}