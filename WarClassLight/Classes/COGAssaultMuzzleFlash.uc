// ====================================================================
//  Class:  WarClassLight.COGAssaultMuzzleFlash
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class COGAssaultMuzzleFlash extends MuzzleFlashAttachment;

#exec OBJ LOAD FILE=..\StaticMeshes\MuzzleFlashes3D_m.usx PACKAGE=MuzzleFlashes3D_m

defaultproperties
{
	FlashLightType=1
	FlashLightEffect=13
	LightBrightness=1024
	LightRadius=8
	LightHue=28
	LightSaturation=32
	DrawType=8
	StaticMesh=StaticMesh'MuzzleFlashes3D_m.Muzzle3D-1_M'
	DrawScale=0.5
}