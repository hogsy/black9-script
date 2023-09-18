//=============================================================================
// skill_Healing
//
// Character Modification
// lets players recover only a small amount of focus, even with a high skill level.
// 
//=============================================================================

class skill_Healing extends B9_Skill;
//    Native
//    NativeReplication;
 

// Functions 
function Activate()
{
	log( "## Healing::Activate()" );
	fFocusUseTimer=0.0;
	GotoState('Active');
}

function int FinalSkillStrength()
{
		local B9_AdvancedPawn		advPawn;
		local int final_healing;

		final_healing = fStrength;

		advPawn			= B9_AdvancedPawn( Owner );
		if( advPawn != none )
		{
			final_healing = fStrength + advPawn.fCharacterConstitution;
		}
		return final_healing;
}
state Active
{
	function Tick( float deltaTime )
	{
		local B9_AdvancedPawn		OwnerPawn;

		OwnerPawn			= B9_AdvancedPawn( Owner );
  		if( ( OwnerPawn != None && OwnerPawn.UsingConstantSkill() ) == false )
   		{
   			GotoState('');
   		}
   		else
   		{
   			Log("## Healing...." ); 
   		}
		fFocusUseTimer += DeltaTime;
  		if( fFocusUseTimer >= fTimeBetweenFocusUses && OwnerPawn.Health < OwnerPawn.fCharacterMaxHealth)
  		{
  			UseFocus();
  			fFocusUseTimer = 0.0;
			OwnerPawn.Health += ( float( FinalSkillStrength() )/ 100.0 ) * 10;
			if( OwnerPawn.Health > OwnerPawn.fCharacterMaxHealth )
			{
				OwnerPawn.Health = OwnerPawn.fCharacterMaxHealth;
			}
  		}
		
	}
}

defaultproperties
{
	fActivatable=true
	fSkillName="Healing"
	fUniqueID=3
	fSkillType=1
	fFocusUsePerActivation=1
	fTimeBetweenFocusUses=0.1
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Healing_bricon'
}