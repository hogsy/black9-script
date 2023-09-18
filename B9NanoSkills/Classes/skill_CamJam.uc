//=============================================================================
// skill_CamJam
//
// Character Modification
// Jams cameras within 5m for up to 60s depending on user's skill level.
// 
//=============================================================================

class skill_CamJam extends B9_Skill;
var fx_CamJam	fCamJamFX;
var fx_CamJamPlayerSparkle fSparkle;
var int fFocusCost;
//    Native
//    NativeReplication;
 

// Functions 
function int SkillFeedBack( Actor interactingActor, eSkillResponseCodes ResponseCode, int numericData , string KeyCode)
{
	// This is pretty simple (for a more complex use of this function see Hacking
	return FinalSkillStrength();
}
function int FinalSkillStrength()
{
	local B9_AdvancedPawn		advPawn;
	local int dex;
	dex = fStrength;

	advPawn			= B9_AdvancedPawn( Owner );
	if( advPawn != none )
	{
		dex = fStrength + advPawn.fCharacterDexterity;
	}
	return dex;
}

//////////////////////////////////
// Functions
//
function ServerActivate()
{
	local B9_AdvancedPawn	P;	


//	log( "#### "$Class.Name$"::ServerActivate()" );

	if( !CheckFocus() )
	{
		return;
	}
//	log( "#### "$Class.Name$"::ServerActivate() post focus check" );
	P = B9_AdvancedPawn( Owner );
	P.PlayNanoAttack();
}
simulated function FireNano()
{
	local Vector Start, X,Y,Z;
	
	local int FinalSkill;
	local B9_AI_ControllerBase A;
	local B9_AdvancedPawn	P;

//	log( "#### "$Class.Name$"::FireNano()" );
	P = B9_AdvancedPawn( Owner );
	FinalSkill = FinalSkillStrength();
	// ReduceFocus returns true if and only if the player character has enough focus
	ForEach DynamicActors( class 'B9_AI_ControllerBase', A )
	{

		if( A != None && A.IsA('B9_AutomationSecurityCameraController') )
		{
//			log("Found a Camera!");
			A.Trigger( self,  Pawn(  Owner ) );
		}
	}
	if( fCamJamFX != None )
	{
		fCamJamFX.Destroy();
		fCamJamFX = None;
	}
	fCamJamFX = Spawn( class'fx_CamJam', P, , P.Location, P.Rotation );
	
	if( fSparkle != None )
	{
		fSparkle.Destroy();
		fSparkle = None;
	}
	fSparkle = Spawn( class'fx_CamJamPlayerSparkle', P, , P.Location, P.Rotation );

	UseFocus();
}
simulated function Activate()
{
//	log( "#### "$Class.Name$"::Activate()" );
	ServerActivate();
	if( Role < ROLE_Authority )
	{
		B9_AdvancedPawn( Owner ).PlayNanoAttack();
	}
}





defaultproperties
{
	fFocusCost=5
	fActivatable=true
	fSkillName="CamJam"
	fUniqueID=21
	fFocusUsePerActivation=5
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.CamJam_bricon'
}