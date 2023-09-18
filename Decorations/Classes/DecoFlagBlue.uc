
class DecoFlagBlue extends Decoration;

#exec MESH IMPORT MESH=newflag ANIVFILE=..\botpack\MODELS\newflag_a.3d DATAFILE=..\botpack\MODELS\newflag_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=newflag X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=newflag SEQ=All     STARTFRAME=0 NUMFRAMES=144
#exec MESH SEQUENCE MESH=newflag SEQ=newflag STARTFRAME=0 NUMFRAMES=144

#exec TEXTURE IMPORT NAME=JpflagB FILE=..\botpack\MODELS\N-Flag-B.PCX GROUP=Skins MASKED=1 // twosided
#exec TEXTURE IMPORT NAME=JpflagR FILE=..\botpack\MODELS\N-Flag-R.PCX GROUP=Skins MASKED=1 // twosided

#exec MESHMAP NEW   MESHMAP=newflag MESH=newflag
#exec MESHMAP SCALE MESHMAP=newflag X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=newflag NUM=0 TEXTURE=JpflagB

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('newflag');
}

defaultproperties
{
	bStatic=false
	Mesh=VertMesh'NewFlag'
	Skins=/* Array type was not detected. */
}