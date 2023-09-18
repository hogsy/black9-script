class WarGeistHeavy extends WarCogHeavy;

#exec OBJ LOAD FILE=..\Sounds\HeavyGunner.uax PACKAGE=HeavyGunner
#exec OBJ LOAD FILE=..\Textures\sg_Hud.utx PACKAGE=SG_Hud
#exec OBJ LOAD FILE=..\animations\GeistHeavySoldiers.ukx PACKAGE=GeistHeavySoldiers

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
}

function name GetWeaponBoneFor(Inventory I)
{
	return 'lower_back';
}


simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;

	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );

	if ( AnimSequence!='deploy' && AnimSequence!='undeploy' && AnimSequence!='Deploy_cyc' )
		PlayAnim('death_1',1.0, 0.1);

}

simulated event PlayJump()
{
	PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	CurrentDir = DCLICK_None;
	LoopIfNeeded('hover_forward',1.0,0.1);	
}

simulated function PlayFiring(float Rate, name FiringMode)
{
	AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE);

	if (FiringMode=='missleleft')
		PlayAnim('shoot_rocket_right',Rate,0.05, FIRINGCHANNEL);

	else if (FiringMode=='missleright')
		PlayAnim('shoot_rocket_right',Rate,0.05, FIRINGCHANNEL);

	else // if ( (Physics == PHYS_Walking) && !bIsCrouched )
		LoopAnim('shoot_both_cyc',Rate,0.25, FIRINGCHANNEL);

}


simulated function AnimateWalking()			// Should be moved to WarfarePawn when all meshes have walks
{
	if (!bJets)
	{
		MovementAnims[0] = 'Walk_forward';
		MovementAnims[2] = 'Walk_Left';
		MovementAnims[1] = 'Walk_Back';
		MovementAnims[3] = 'Walk_Right';
	}
	else
	{
		MovementAnims[0] = 'Hover_forward';
		MovementAnims[2] = 'Hover_Left';
		MovementAnims[1] = 'Hover_Back';
		MovementAnims[3] = 'Hover_Right';
	}
}

simulated function PlayDeployOut()
{
	PlaySound(sound 'HeavyGunner.Deploy.hg_deploy',SLOT_Misc,1.0);
	PlayAnim('Deploy_Out',1.0,0.25);
	DesiredWeapXMod.X=0;
}

simulated function name GetMissleBoneFor(name Side)
{
	if (Side=='left')
		return 'l_wrist';
	else
		return 'r_wrist';
		
}		


defaultproperties
{
	Helmet=StaticMesh'character_helmetmeshes.Geist_helmets.GeistHeavyGunnerMask1'
	RequiredEquipment="WarClassHeavy.WeapGeistMinigun"
	GroundSpeed=150
	WaterSpeed=200
	JumpZ=220
	CrouchHeight=60
	CrouchRadius=50
	MenuName="Geist Heavy Soldier"
	BaseMovementRate=150
	Mesh=SkeletalMesh'GeistHeavySoldiers.GeistGunnerMesh'
}