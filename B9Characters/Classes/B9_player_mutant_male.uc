//===============================================================================
//  [B9_player_mutant_male] 
//===============================================================================

class B9_player_mutant_male extends B9_PlayerPawn;

function name GetWeaponBoneFor(Inventory I)
{
	return 'weaponbone';
}


function WeaponHit()
{
	//	log( "WeaponHit!!!!!" );
	//	bMeleeAttack=false;
	//	ChangeAnimation();
}



function Touch( Actor Other )
{
	PlayerController(Controller).Touch( Other );
}

function UnTouch( Actor Other )
{
	PlayerController(Controller).UnTouch( Other );
}


auto state BaseState
{
	function BeginState()
	{
		SetTimer(0.1, false);
	}

	function EndState()
	{
		SetTimer(0.0, false);
	}
}


function bool IsPlayer()
{
	return true;
}


// !!!! TEST CODE: immunity to unclassified damage
function bool ImmuneToDamage( Pawn instigatedBy, Vector hitlocation, class<DamageType> damageType )
{
	/* AFSNOTE: Taken out to do play testing - replace with actual immunites to reinstate.
	Log("Player hit by " $ damageType.Name);
	return (damageType == class'DamageType');
	*/

	return false;
}
// END TEST CODE

defaultproperties
{
	Helmet=StaticMesh'B9_CharAccessories_meshes.Exosuits.MutantHelm_hwb'
	AffiliationSkins[0]=Shader'B9_Players_tex.Mutant_male.Mmutant01'
	AffiliationSkins[1]=Shader'B9_Players_tex.Mutant_male.Mmutant02'
	AffiliationSkins[2]=Shader'B9_Players_tex.Mutant_male.Mmutant03'
	AffiliationSkins[3]=Shader'B9_Players_tex.Mutant_male.Mmutant04'
	AffiliationSkins[4]=Shader'B9_Players_tex.Mutant_male_blue.Mmutant01Blue_shader'
	AffiliationSkins[5]=Shader'B9_Players_tex.Mutant_male_blue.Mmutant02Blue_shader'
	AffiliationSkins[6]=Shader'B9_Players_tex.Mutant_male_blue.Mmutant03Blue_shader'
	AffiliationSkins[7]=Shader'B9_Players_tex.Mutant_male_blue.Mmutant04Blue_shader'
	AffiliationSkins[8]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant01Gold_shader'
	AffiliationSkins[9]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant02Gold_shader'
	AffiliationSkins[10]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant03Gold_shader'
	AffiliationSkins[11]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant04Gold_shader'
	AffiliationSkins[12]=Shader'B9_Players_tex.Mutant_male_red.Mmutant01Red_shader'
	AffiliationSkins[13]=Shader'B9_Players_tex.Mutant_male_red.Mmutant02Red_shader'
	AffiliationSkins[14]=Shader'B9_Players_tex.Mutant_male_red.Mmutant03Red_shader'
	AffiliationSkins[15]=Shader'B9_Players_tex.Mutant_male_red.Mmutant04Red_shader'
	JumpSound=Sound'B9PlayerCharacters_sounds.MutantMale.gruber_jump1'
	FallingSound=Sound'B9PlayerCharacters_sounds.MutantMale.gruber_fall'
	FallingVolume=1
	fCharacterName="Gruber"
	fCharacterBaseStrength=50
	fCharacterBaseAgility=20
	fCharacterBaseDexterity=20
	fCharacterBaseConstitution=50
	fMeleeAttackDamage=8
	FootstepVolume=0.25
	DeathVolume=1
	HurtSound1=Sound'B9PlayerCharacters_sounds.MutantMale.gruber_shot1'
	HurtSound2=Sound'B9PlayerCharacters_sounds.MutantMale.gruber_shot2'
	HurtSound3=Sound'B9PlayerCharacters_sounds.MutantMale.gruber_shot3'
	AirSpeed=1000
	JumpZ=540
	WalkingPct=0.25
	CrouchedPct=0.25
	bPhysicsAnimUpdate=true
	MovementAnims[0]=nowpn_Run_F
	MovementAnims[1]=nowpn_Run_B
	MovementAnims[2]=nowpn_Run_Step_L
	MovementAnims[3]=nowpn_Run_Step_R
	Mesh=SkeletalMesh'B9_Player_Characters.mutant_male_mesh'
}