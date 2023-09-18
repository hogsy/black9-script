// ====================================================================
//  Class:  WarEffects.EffectWaterSplash
//  Parent: Engine.Effects
//
//  <Enter a description here>
// ====================================================================

class EffectWaterSplash extends Effects;

#exec OBJ LOAD FILE=..\StaticMeshes\N_StaticMeshFX_M_SC.usx PACKAGE=N_StaticMeshFX_M_SC

defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'N_StaticMeshFX_M_SC.WaterFX.N_Splash2_M_SC'
	LifeSpan=0.25
}