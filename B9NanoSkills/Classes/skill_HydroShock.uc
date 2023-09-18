//=============================================================================
// skill_HydroShock.uc
//
//	Tsunami skill (fka Hydro Shock)
//
//=============================================================================


class skill_HydroShock extends B9_Skill;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
//

//////////////////////////////////
// Variables
//
var NanoFX_HydroShock		fFX;
var float					fLifetime;
const						kMaxLifetime = 5.0;


//////////////////////////////////
// Functions
//

function ServerActivate()
{
	local Pawn P;

	if( !CheckFocus() )
	{
		return;
	}

	P = Pawn( Owner );

	if( fFX != None )
	{
		fFX.Destroy();
		fFX = None;
	}

	fFX = Spawn( class'NanoFX_HydroShock', P, ,P.Location, P.Rotation );
	P.AttachToBone( fFX, 'ShieldBone' );

	UseFocus();
	GotoState('Active');
}

simulated function Activate()
{
	ServerActivate();
}


event Destroyed()
{
	if( fFX != None )
	{
		fFX.Destroy();
		fFX = None;
	}

	Super.Destroyed();
}

//////////////////////////////////
// States
//

state Active
{
	function Activate();

	simulated function Tick( float DeltaTime )
	{
		fLifetime += DeltaTime;
		if( fLifetime >= kMaxLifetime )
		{
			if( fFX != None )
			{
				fFX.Destroy();
				fFX = None;
			}

			fLifetime=0.0;
			GotoState('');
		}
	}
}

//////////////////////////////////
// Initialization
//


defaultproperties
{
	fActivatable=true
	fSkillName="Hydro Shock"
	fUniqueID=14
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Tsunami_bricon'
}