//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Zubrin Marine.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantZubrinMarine extends B9_ArchetypePawnCombatantGenesisMediumGuard;

// Load the textures package for the genesis archetype
#exec OBJ LOAD FILE=..\textures\B9_Zubrin_Textures.utx PACKAGE=B9_Zubrin_Textures


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Skins.Length == 0 )
	{
		CopyMaterialsToSkins();
	}

	Skins[0] = shader'B9_Zubrin_Textures.Marine.ZM_Shad0';
}
