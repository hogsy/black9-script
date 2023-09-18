//=============================================================================
// WarCogGeneral.
//=============================================================================
class WarCogGeneral extends CogLightInfantry;

#exec MESH  MODELIMPORT MESH=COGGeneral MODELFILE=..\WarClassContent\models\Cog_general.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=COGGeneral X=0 Y=10 Z=0 YAW=-64 PITCH=0 ROLL=64
#exec ANIM  IMPORT ANIM=GeneralAnim ANIMFILE=..\WarClassContent\models\Cog_general.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=COGGeneral X=8.0 Y=8.0 Z=8.0

#exec MESH  DEFAULTANIM MESH=COGGeneral ANIM=GeneralAnim

#exec ANIM DIGEST  ANIM=GeneralAnim USERAWINFO VERBOSE 

#exec OBJ LOAD FILE=..\textures\cogsoldiers.utx PACKAGE=CogSoldiers

function PlayWaiting()
{
	LoopAnim('Idle1',1,0.15);
}

defaultproperties
{
	MenuName="COG General"
	Mesh=SkeletalMesh'COGGeneral'
	Skins=/* Array type was not detected. */
}