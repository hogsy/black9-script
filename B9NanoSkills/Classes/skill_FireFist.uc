//=============================================================================
// skill_FireFist.uc
//
//	Fire Fist skill
//
//=============================================================================


class skill_FireFist extends B9_Skill;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
//

//////////////////////////////////
// Variables
//

var NanoFX_FireFist		fFX;
var float				fLifetime;
const					kMaxLifetime = 30.0;


//////////////////////////////////
// Functions
//


simulated function SpawnFX()
{
	local Vector Start, X,Y,Z;

	if( fFX == None )
	{
		fFX	= Spawn( class'NanoFX_FireFist', Self, , Owner.Location, Owner.Rotation );
	}

	Owner.AttachToBone(fFX, 'NanoBone');
}

function ServerActivate()
{
	if( !CheckFocus() )
	{
		return;
	}

	SpawnFX();
	UseFocus();

	GotoState( 'Active' );
}

simulated function Activate()
{
	if( !CheckFocus() )
	{
		return;
	}

	ServerActivate();

	if( Role < ROLE_Authority )
	{
		SpawnFX();
		GotoState( 'Active' );
	}
}

simulated event Destroyed()
{
	if( fFX != None )
	{
		fFX.Destroy();
	}

	Super.Destroyed();
}

simulated function int GetDamage()
{
	return 10;
}

//////////////////////////////////
// States
//

simulated state Active
{
	simulated function Activate(); // Do nothing in this state

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

	simulated function BeginState()
	{
		fActive = true;
	}
	simulated function EndState()
	{
		fActive = false;
	}
}



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fActivatable=true
	fSkillName="Fire Fist"
	fUniqueID=4
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Firefist_bricon'
}