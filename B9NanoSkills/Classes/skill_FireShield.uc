//=============================================================================
// skill_FireShield.uc
//
//	Fire Shield skill
//
//=============================================================================


class skill_FireShield extends B9_Skill;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
//

//////////////////////////////////
// Variables
//
var NanoFX_FireShield		fShield;
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

	if( fShield != None )
	{
		fShield.Destroy();
		fShield = None;
	}

	fShield = Spawn( class'NanoFX_FireShield', P, ,P.Location, P.Rotation );
	P.AttachToBone( fShield, 'ShieldBone' );

	UseFocus();
	GotoState('Active');
}

simulated function Activate()
{
	ServerActivate();
}


event Destroyed()
{
	if( fShield != None )
	{
		fShield.Destroy();
		fShield = None;
	}

	Super.Destroyed();
}

//////////////////////////////////
// States
//

state Active
{
	function Activate(); // Do nothing in this state

	simulated function Tick( float DeltaTime )
	{
		fLifetime += DeltaTime;
		if( fLifetime >= kMaxLifetime )
		{
			if( fShield != None )
			{
				fShield.Destroy();
				fShield = None;
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
	fSkillName="Fire Shield"
	fUniqueID=12
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Flash_shield_bricon'
}