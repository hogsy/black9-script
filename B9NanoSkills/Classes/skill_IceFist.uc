//=============================================================================
// skill_IceFist.uc
//
//	Ice Fist skill
//
//=============================================================================


class skill_IceFist extends B9_Skill;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
//

//////////////////////////////////
// Variables
//

var NanoFX_IceFist		fFX;
var float				fLifetime;
const					kMaxLifetime = 30.0;


//////////////////////////////////
// Functions
//


function Activate()
{
	local Vector Start, X,Y,Z;
	local Pawn				P;

	if( !CheckFocus() )
	{
		return;
	}

	P = Pawn( Owner );

	if( fFX == None )
	{
		fFX	= Spawn( class'NanoFX_IceFist', Self, , Owner.Location, Owner.Rotation );
		P.AttachToBone(fFX, 'NanoBone');
	}

	fFX.SpawnIceDust();
	

	UseFocus();

	GotoState('Active');
}

event Destroyed()
{
	if( fFX != None )
	{
		fFX.Destroy();
	}

	Super.Destroyed();
}


//////////////////////////////////
// States
//

state Active
{
	function Activate(); // Do nothing in this state

	function Tick( float DeltaTime )
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
	fSkillName="Ice Fist"
	fUniqueID=5
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.iceFist_bricon'
}