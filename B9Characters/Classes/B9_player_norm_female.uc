//===============================================================================
//  [B9_player_norm_female] 
//===============================================================================

class B9_player_norm_female extends B9_PlayerPawn;


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
	BackPack=StaticMesh'B9_CharAccessories_meshes.Exosuits.NormalO2Pack_hwb'
	AffiliationSkins[0]=Shader'B9_Players_tex.Normal_Female.FProt02_shad'
	AffiliationSkins[1]=Shader'B9_Players_tex.Normal_Female.FProt01_shad'
	AffiliationSkins[2]=Shader'B9_Players_tex.Normal_Female.FProt03_shad'
	AffiliationSkins[3]=Shader'B9_Players_tex.Normal_Female.FProt04_shad'
	AffiliationSkins[4]=Shader'B9_Players_tex.Normal_Female_blue.Fprotag02Blue_shader'
	AffiliationSkins[5]=Shader'B9_Players_tex.Normal_Female_blue.Fprotag01Blue_shader'
	AffiliationSkins[6]=Shader'B9_Players_tex.Normal_Female_blue.Fprotag03Blue_shader'
	AffiliationSkins[7]=Shader'B9_Players_tex.Normal_Female_blue.Fprotag04Blue_shader'
	AffiliationSkins[8]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag02Gold_shader'
	AffiliationSkins[9]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag01Gold_shader'
	AffiliationSkins[10]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag03Gold_shader'
	AffiliationSkins[11]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag04Gold_shader'
	AffiliationSkins[12]=Shader'B9_Players_tex.Normal_Female_red.Fprotag02Red_shader'
	AffiliationSkins[13]=Shader'B9_Players_tex.Normal_Female_red.Fprotag01Red_shader'
	AffiliationSkins[14]=Shader'B9_Players_tex.Normal_Female_red.Fprotag03Red_shader'
	AffiliationSkins[15]=Shader'B9_Players_tex.Normal_Female_red.Fprotag04Red_shader'
	JumpSound=none
	FallingSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_fall_down1'
	FallingVolume=1
	fCharacterName="Sahara"
	fCharacterBaseAgility=40
	fCharacterBaseDexterity=35
	fCharacterBaseConstitution=45
	fIsLeftHanded=true
	DeathSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_death1'
	HurtSound1=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_shot1'
	HurtSound2=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_shot2'
	HurtSound3=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_shot3'
	AirSpeed=1000
	JumpZ=540
	WalkingPct=0.25
	CrouchedPct=0.25
	BaseEyeHeight=72
	bPhysicsAnimUpdate=true
	MovementAnims[0]=nowpn_Run_F
	MovementAnims[1]=nowpn_Run_B
	MovementAnims[2]=nowpn_Run_Step_L
	MovementAnims[3]=nowpn_Run_Step_R
	Mesh=SkeletalMesh'B9_Player_Characters.Normal_Female_mesh'
}