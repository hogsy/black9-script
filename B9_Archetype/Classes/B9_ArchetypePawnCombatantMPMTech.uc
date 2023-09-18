//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype MPM Tech.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantMPMTech extends B9_ArchetypePawnCombatantGenesisLightGuard;

// Load the textures package for the genesis archetype
#exec OBJ LOAD FILE=..\textures\B9_MPM_DGP_Textures.utx PACKAGE=B9_MPM_DGP_Textures


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Skins.Length == 0 )
	{
		CopyMaterialsToSkins();
	}

	Skins[0] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_tech.mpm_spacesuit_tech_1';
	Skins[1] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_tech.mpm_spacesuit_tech_3';
	Skins[2] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_tech.mpm_spacesuit_tech_2';
	Skins[3] = texture'B9_MPM_DGP_Textures.mpm_spacesuit_tech.mpm_spacesuit_tech_4';
}
