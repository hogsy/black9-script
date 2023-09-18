//=============================================================================
// skill_OpticCloak.uc
//
//	Optic Cloak Skill
//
//=============================================================================


class skill_OpticCloak extends B9_Skill;


//////////////////////////////////
// Functions
//

function ServerActivate()
{
	local B9_AdvancedPawn	P;	
	local Controller		C;

	if( !CheckFocus() )
	{
		return;
	}

	P = B9_AdvancedPawn( Owner );
	if( P == None )
	{
		return;
	}
	
	C = P.Controller;
	if( C != None )
	{
		C.Cloak( 0 );
		UseFocus();
	}
}

simulated function Activate()
{
	ServerActivate();
}

function AIActivate( Rotator aimRotation )
{
	ServerActivate();
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fActivatable=true
	fSkillName="Optic Cloak"
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Optic_cloak_bricon'
}