//===============================================================================
//  [B9_player_norm_male] 
//===============================================================================

class B9_player_norm_male extends B9_PlayerPawn;


//var AssassinShadow		Shadow;		//for simple oval shadow
//var vector			ShadowOffset;	//for simple oval shadow
//var ShadowProjector		Shadow;		//for detailed shadow

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
	Helmet=StaticMesh'B9_CharAccessories_meshes.Exosuits.NormalHelm_hwb'
	AffiliationSkins[0]=Shader'B9_Players_tex.Normal_male.MProt04_shad'
	AffiliationSkins[1]=Shader'B9_Players_tex.Normal_male.MProt01_shad'
	AffiliationSkins[2]=Shader'B9_Players_tex.Normal_male.MProt03_shad'
	AffiliationSkins[3]=Shader'B9_Players_tex.Normal_male.MProt02_shad'
	AffiliationSkins[4]=Shader'B9_Players_tex.Normal_male_blue.Mprotag04Blue_shader'
	AffiliationSkins[5]=Shader'B9_Players_tex.Normal_male_blue.Mprotag01Blue_shader'
	AffiliationSkins[6]=Shader'B9_Players_tex.Normal_male_blue.Mprotag03Blue_shader'
	AffiliationSkins[7]=Shader'B9_Players_tex.Normal_male_blue.Mprotag02Blue_shader'
	AffiliationSkins[8]=Shader'B9_Players_tex.Normal_male_gold.Mprotag04Gold_shader'
	AffiliationSkins[9]=Shader'B9_Players_tex.Normal_male_gold.Mprotag01Gold_shader'
	AffiliationSkins[10]=Shader'B9_Players_tex.Normal_male_gold.Mprotag03Gold_shader'
	AffiliationSkins[11]=Shader'B9_Players_tex.Normal_male_gold.Mprotag02Gold_shader'
	AffiliationSkins[12]=Shader'B9_Players_tex.Normal_male_red.Mprotag04Red_shader'
	AffiliationSkins[13]=Shader'B9_Players_tex.Normal_male_red.Mprotag01Red_shader'
	AffiliationSkins[14]=Shader'B9_Players_tex.Normal_male_red.Mprotag03Red_shader'
	AffiliationSkins[15]=Shader'B9_Players_tex.Normal_male_red.Mprotag02Red_shader'
	JumpSound=Sound'B9PlayerCharacters_sounds.NormalMale.jake_jump1'
	FallingSound=Sound'B9PlayerCharacters_sounds.NormalMale.jake_fall_down1'
	FallingVolume=1
	fCharacterName="Jake"
	fCharacterBaseAgility=40
	fCharacterBaseDexterity=35
	fCharacterBaseConstitution=45
	fMeleeAttackDamage=6
	FootstepVolume=0.25
	DeathSound=none
	DeathVolume=1
	HurtSound1=Sound'B9PlayerCharacters_sounds.NormalMale.jake_shot1'
	HurtSound2=Sound'B9PlayerCharacters_sounds.NormalMale.jake_shot2'
	HurtSound3=Sound'B9PlayerCharacters_sounds.NormalMale.jake_shot3'
	AirSpeed=1000
	JumpZ=540
	WalkingPct=0.25
	CrouchedPct=0.25
	bPhysicsAnimUpdate=true
	MovementAnims[0]=nowpn_Run_F
	MovementAnims[1]=nowpn_Run_B
	MovementAnims[2]=nowpn_Run_Step_L
	MovementAnims[3]=nowpn_Run_Step_R
	Mesh=SkeletalMesh'B9_Player_Characters.normal_male_mesh'
}