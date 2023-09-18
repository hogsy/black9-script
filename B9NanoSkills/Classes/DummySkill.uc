//=============================================================================
// DummySkill
//
// Character Modification
//
// 
//=============================================================================

Class DummySkill extends B9_Skill;
//    Native
//    NativeReplication;
 

// Functions 

function ModifyAttributes( B9_AdvancedPawn pawn )
{
	pawn.fCharacterStrength += fStrength;
}

function UnModifyAttributes( B9_AdvancedPawn pawn )
{
	pawn.fCharacterStrength -= fStrength;
}

function PawnTick( Pawn pawn, float deltaTime )
{
}

defaultproperties
{
	fSkillName="Dummy Skill"
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser.Defocus_BrIcon_tex'
}