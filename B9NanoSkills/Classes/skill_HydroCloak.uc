//=============================================================================
// skill_HydroCloak.uc
//
//	Hydro Cloak Skill
//
//=============================================================================


class skill_HydroCloak extends B9_Skill;


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
		C.Cloak( 1 );
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
	fSkillName="Hydro Cloak"
	fUniqueID=13
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Hydro_cloak_bricon'
}