//=============================================================================
// GlassFragments.
//=============================================================================
class GlassFragments extends Fragment;

#exec AUDIO IMPORT FILE="..\botpack\Sounds\General\Tink1.WAV" NAME="GlassTink1" GROUP="General"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\General\Tink2.WAV" NAME="GlassTink2" GROUP="General"

#exec MESH IMPORT MESH=Glass1 ANIVFILE=..\botpack\MODELS\Glass1_a.3D DATAFILE=..\botpack\MODELS\Glass1_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass1 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass1 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass1 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass1 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass2 ANIVFILE=..\botpack\MODELS\Glass2_a.3D DATAFILE=..\botpack\MODELS\Glass2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass2 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass2 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass2 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass2 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass3 ANIVFILE=..\botpack\MODELS\Glass3_a.3D DATAFILE=..\botpack\MODELS\Glass3_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass3 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass3 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass3 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass3 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass3 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass4 ANIVFILE=..\botpack\MODELS\Glass4_a.3D DATAFILE=..\botpack\MODELS\Glass4_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass4 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass4 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass4 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass4 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass4 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass5 ANIVFILE=..\botpack\MODELS\Glass5_a.3D DATAFILE=..\botpack\MODELS\Glass5_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass5 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass5 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass5 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass5 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass5 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass6 ANIVFILE=..\botpack\MODELS\Glass6_a.3D DATAFILE=..\botpack\MODELS\Glass6_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass6 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass6 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass6 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass6 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass6 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass7 ANIVFILE=..\botpack\MODELS\Glass7_a.3D DATAFILE=..\botpack\MODELS\Glass7_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass7 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass7 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass7 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass7 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass7 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass8 ANIVFILE=..\botpack\MODELS\Glass8_a.3D DATAFILE=..\botpack\MODELS\Glass8_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass8 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass8 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass8 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass8 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass8 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass9 ANIVFILE=..\botpack\MODELS\Glass9_a.3D DATAFILE=..\botpack\MODELS\Glass9_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass9 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass9 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass9 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass9 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass9 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass10 ANIVFILE=..\botpack\MODELS\Glas10_a.3D DATAFILE=..\botpack\MODELS\Glas10_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass10 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass10 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass10 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass10 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass10 NUM=0 TEXTURE=DefaultTexture

#exec MESH IMPORT MESH=Glass11 ANIVFILE=..\botpack\MODELS\Glas11_a.3D DATAFILE=..\botpack\MODELS\Glas11_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Glass11 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=Glass11 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Glass11 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Glass11 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=Glass11 NUM=0 TEXTURE=DefaultTexture

defaultproperties
{
	Fragments[0]=VertMesh'Glass1'
	Fragments[1]=VertMesh'Glass2'
	Fragments[2]=VertMesh'Glass3'
	Fragments[3]=VertMesh'Glass4'
	Fragments[4]=VertMesh'Glass5'
	Fragments[5]=VertMesh'Glass6'
	Fragments[6]=VertMesh'Glass7'
	Fragments[7]=VertMesh'Glass8'
	Fragments[8]=VertMesh'Glass9'
	Fragments[9]=VertMesh'Glass10'
	Fragments[10]=VertMesh'Glass11'
	numFragmentTypes=11
	ImpactSound=Sound'General.GlassTink1'
	AltImpactSound=Sound'General.GlassTink2'
	Mesh=VertMesh'Glass1'
	CollisionRadius=10
	CollisionHeight=2
}