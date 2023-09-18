//=============================================================================
// Torchflame.
//=============================================================================
class TorchFlame extends Light;

#exec MESH IMPORT MESH=TFlameM ANIVFILE=..\Botpack\MODELS\flame_a.3D DATAFILE=..\Botpack\MODELS\flame_d.3D MLOD=0
#exec MESH ORIGIN MESH=TFlameM X=0 Y=100 Z=350 YAW=0
#exec MESH SEQUENCE MESH=TFlameM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec OBJ LOAD FILE=..\Botpack\Textures\fireeffect28.utx PACKAGE=Decorations.Effect28
#exec MESHMAP SCALE MESHMAP=TFlameM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=TFlameM NUM=0 TEXTURE=Decorations.Effect28.FireEffect28
#exec MESHMAP SETTEXTURE MESHMAP=TFlameM NUM=1 TEXTURE=Decorations.Effect28.FireEffect28a

defaultproperties
{
	LightEffect=2
	LightBrightness=40
	LightRadius=32
	DrawType=2
	bStatic=false
	bHidden=false
	Mesh=VertMesh'TFlameM'
	bUnlit=true
}