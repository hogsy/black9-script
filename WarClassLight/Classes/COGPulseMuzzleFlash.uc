// ====================================================================
//  Class:  WarClassLight.COGPulseMuzzleFlash
//  Parent: WarfareGame.MuzzleFlashAttachment
//
//  <Enter a description here>
// ====================================================================

class COGPulseMuzzleFlash extends MuzzleFlashAttachment;

#exec OBJ LOAD FILE=..\StaticMeshes\MuzzleFlashes3D_m.usx PACKAGE=MuzzleFlashes3D_m

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
}

event Destroyed()
{
	Super.Destroyed();
}



defaultproperties
{
	FlashLightType=1
	FlashLightEffect=13
	LightBrightness=1024
	LightRadius=16
	LightHue=130
	LightSaturation=104
	DrawType=8
	StaticMesh=StaticMesh'MuzzleFlashes3D_m.C_Muzzle3DPulse2_M_SC'
	DrawScale=0.5
}