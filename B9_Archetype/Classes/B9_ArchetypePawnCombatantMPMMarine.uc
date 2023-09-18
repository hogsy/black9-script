//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype MPM Marine.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantMPMMarine extends B9_ArchetypePawnCombatantGenesisMediumGuard;

// Load the textures package for the MPM archetype
#exec OBJ LOAD FILE=..\textures\B9_MPM_DGP_Textures.utx PACKAGE=B9_MPM_DGP_Textures


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Skins.Length == 0 )
	{
		CopyMaterialsToSkins();
	}

	Skins[0] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_guard.mpm_spacesuit_1';
	Skins[1] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_guard.mpm_spacesuit_3';
	Skins[2] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_guard.mpm_spacesuit_2';
	Skins[3] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_guard.mpm_spacesuit_4';
}
