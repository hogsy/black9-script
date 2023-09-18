class WarCOGHeavy extends CogHeavyInfantry;

#exec OBJ LOAD FILE=..\Sounds\HeavyGunner.uax PACKAGE=HeavyGunner
#exec OBJ LOAD FILE=..\Textures\sg_Hud.utx PACKAGE=SG_Hud
#exec OBJ LOAD FILE=..\Sounds\WarfareExplosion.uax PACKAGE=WarfareExplosion

var int side;
var vector DesiredWeapXMod, WeapXMod;	// Used to slide the weapon in/out
var int LastMissleFire, MissleFire;		// Incremented when a missle fires. 
var PclCOGHeavyDeathSmoke Smoke;
var bool Deploying;
 
replication
{
	reliable if ( ROLE<ROLE_Authority )
		ServerDeploy, ServerUnDeploy;
		
	reliable if (ROLE==ROLE_Authority)
		MissleFire;

}	

simulated function SwitchToHover()
{
	if (bJets)
		PlayAnim( 'Hover',1.0,0.5);
}

simulated event PlayJump()
{
	PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	CurrentDir = DCLICK_None;
	LoopIfNeeded('Jump_Stand',1.0,0.1);	
}

simulated function PlayFootstep()
{
	local float pitch;

	if (ROLE==ROLE_Authority && !IsLocallyControlled() )
		return;

	pitch = (frand()*10)-5;

	//if ( (side & 0x01)==0x01 )
		PlaySound(sound 'HeavyGunner.Footsteps.hg_step_left_2',SLOT_Misc,1.0,,512,pitch);
	//else
	//	PlaySound(sound 'HeavyGunner.Footsteps.hg_step_right_1',SLOT_Misc,1.0,,512,pitch);
	
	side++;
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;

	Super.DisplayDebug(Canvas,YL,YPos);
	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawText("bWantsToCrouch: "$bWantsToCrouch$" bIsCrouched: "$bIsCrouched$" Deploying: "$Deploying);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );
	Canvas.DrawText("AnimSequence: "$AnimSequence);
	YPos += YL;
	Canvas.SetPos(4,YPos);

}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;

	bAlreadyDead = (Health <= 0);

	// This doesn't happen when deployed
	
	if (!bIsCrouched)
	{
		if (Physics == PHYS_None)
			SetMovementPhysics();
		if (Physics == PHYS_Walking)
			momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
		if ( instigatedBy == self )
			momentum *= 0.6;
		momentum = momentum/Mass;
	}

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
	{
		Warn(self$" took regular damage "$damagetype$" from "$instigatedby$" while already dead at "$Level.TimeSeconds);
		ChunkUp(Rotation, DamageType);
		return;
	}

	PlayHit(actualDamage, InstigatedBy, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{
		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.Controller; //FIXME what if killer died before killing you
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		if (!bIsCrouched)
			AddVelocity( momentum );
			 
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}
	MakeNoise(1.0); 
}

function vector ModifiedPlayerViewOffset(Inventory Inv)
{
	return WeapXMod + Inv.PlayerViewOffset;
}

simulated function vector CalcCanopyOffset(inventory Inv)
{
	local vector DrawOffset;

	if ( Controller == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	DrawOffset = ((0.9/Controller.FOVAngle * 100 * Inv.PlayerViewOffset) >> GetViewRotation() );
	if ( !IsLocallyControlled() )
		DrawOffset.Z += BaseEyeHeight;
	else
	{	
		DrawOffset.Z += EyeHeight;
		DrawOffset += WeaponBob(Inv.BobDamping);
	}
	return DrawOffset;
}

simulated function rotator GetViewRotation()
{
	if ( Controller == None )
		return Rotation;
	else if (Warfareplayer(Controller) == None || WarfarePlayer(Controller).AimControl == None || !WarfarePlayer(Controller).AimControl.bActive)
		return Controller.Rotation;
	else
	{
		return Controller.Rotation + WarfarePlayer(Controller).ViewChange;
	}
}


// ToggleAim - Tells the Controller to go to/from the alternate aim control

simulated function StartAim()
{

	if ( isLocallyControlled() )	// Clients only please
	{
		WarfarePlayer(Controller).ChangeAim(true);
	}
	else
	{
		if ( WarfarePlayer(Controller) != None )
			WarfarePlayer(Controller).GotoState('deployed');
	}
}

simulated function EndAim()
{
	if ( isLocallyControlled() )	// Clients only please
	{
		WarfarePlayer(Controller).ChangeAim(False);
		Weapon.GotoState('Idle');
		ServerUnDeploy();
	}
 
}

function ServerUnDeploy()
{
	if ( WarfarePlayer(Controller) != None )
		WarfarePlayer(Controller).GotoState('PlayerWalking');
}

function ShouldCrouch(bool Crouch)
{

	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;
	
	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );

	// Check to see if we are deployed 

	if (AnimSequence=='deploy' || AnimSequence=='deploy_cyc' || AnimSequence=='undeploy')
	{
		return;
	}
	
	if (Crouch)
	{
		bWantsToCrouch = true;
		if (Role==Role_Authority)
			ServerDeploy(true);
	}
	else
	{
		bWantsToCrouch = Crouch;
	}
	
}

function ShouldUnCrouch()
{
	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;

	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );

	if (AnimSequence=='deploy_cyc')
	{
		bWantsToCrouch = false;

		if (Role==Role_Authority)
			PlayDeployOut();
	}

}
function ServerDeploy(bool In)
{
	// If we are jetting, turn it off

	if (bJets)
		ToggleJets(false);
	
	if (In)
	{
	
		Velocity=vect(0,0,0);		// Stop the player
		PlayDeployIn();
		if ( WarfarePlayer(Controller)!= None )
			WarfarePlayer(Controller).Deploy();	
	}
}

simulated function PlayDeployIn()
{
	if (Controller != None)
		Controller.StopFiring();
	
	if (Weapon!=None)
	{
		Weapon.GotoState('Idle');

		if ( Weapon.IsA('WeapCOGMinigun') )
			Weapon.PlayAnim('SpinDown');
	
	}
	
	PlaySound(sound 'HeavyGunner.Deploy.hg_deploy',SLOT_Misc,1.0);
	DesiredWeapXMod.X = -20; 	
	PlayAnim('Deploy',1.0,0.25);
}

simulated function PlayDeployOut()
{
	PlaySound(sound 'HeavyGunner.Deploy.hg_deploy',SLOT_Misc,1.0);
	PlayAnim('UnDeploy',1.0,0.25);
	DesiredWeapXMod.X=0;
}

simulated function ChangeAnimation()
{
	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;

	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );

	if (bIsCrouched)
	{
		// Determine what crouch state you are in
	
		if (AnimSequence!='deploy')
		{
			PlayDeployIn();
		}
	}
	else if (AnimSequence=='deploy_cyc')
	{
		PlayDeployOut();
	}
	else if ( (AnimSequence!='Deploy') && (AnimSequence!='UnDeploy') )
	{
		Super.ChangeAnimation();
	}
			
}

simulated function PlayWaiting()
{

	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;
	
	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );

	if ( (AnimSequence=='Deploy') || (AnimSequence=='deploy_cyc') )
		PlayAnim('deploy_cyc');
	else 
	{	
		Super.PlayWaiting();
	}
}

simulated function PlayFiring(float Rate, name FiringMode)
{
	if ( bIgnorePlayFiring )
		return;
	AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE);

	if (FiringMode=='missleleft')
	{
		PlaySound(sound'WarfareExplosion.explode.explosion_small1',,1.0,,384);
		PlayAnim('deploy_shoot_left',Rate,0.05, FIRINGCHANNEL);
	}

	else if (FiringMode=='missleright')
	{
		PlaySound(sound'WarfareExplosion.explode.explosion_small1',,1.0,,384);
		PlayAnim('deploy_shoot_right',Rate,0.05, FIRINGCHANNEL);
	}

	else // if ( (Physics == PHYS_Walking) && !bIsCrouched )
		LoopAnim('shoot_auto',Rate,0.05, FIRINGCHANNEL);

}

simulated function AnimateCrouching()
{

	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;
	
	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );
	
	if (AnimSequence!='undeploy')
		LoopIfNeeded('deploy_cyc',1.0,0.25);
}


simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying(DamageType, HitLoc);

	if (Smoke==None)
	{
		Smoke = Spawn(class'PclCOGHeavyDeathSmoke',Owner,,location);
		AttachToBone(Smoke,'canopy');
	}

}

simulated event Destroyed()
{
	if (Smoke!=None)
	{
		DetachFromBone(Smoke);
		Smoke.Emitters[0].AutomaticInitialSpawning=False;
		Smoke.Emitters[0].RespawnDeadParticles=false;
		Smoke.Emitters[0].ParticlesPerSecond=0;
	    Smoke.AutoReset=false;
		Smoke.AutoDestroy=true;
	}

	Super.Destroyed();
}	

State Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;


	function Timer()
	{
		local coords C;
		local vector v;

		if (ROLE<Role_Authority)
			return;

		C = GetBoneCoords('Canopy');
		V = C.Origin;
			
		HurtRadius(400,1024, class'WarDamageExplosionRadius', 20000, v );

		if ( Role == ROLE_Authority )
			MakeNoise(1.0);
		
		spawn(class'BlastMark',,,v,rot(16384,0,0));
  		spawn(class'PclBigExplosion',,,v,rot(16384,0,0));
		PlaySound(sound'WarfareExplosion.WithDebris.explosion_debris1',,2,,786);
		
	 	Destroy();
	}

	function BeginState()
	{
		Super.BeginState();

		if (ROLE<Role_Authority)
			return;

		SetTimer(4.0, false);
	}
}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	if (!bIsCrouched)
	{
		return;
	}
	
	Super.PlayTakeHit(HitLoc, Damage, DamageType);
}

simulated function name GetMissleBoneFor(name Side)
{
	if (Side=='left')
		return 'left_misslepack';
	else
		return 'right_misslepack';
		
}		
	
	

defaultproperties
{
	Helmet=StaticMesh'character_helmetmeshes.cog_helmets.CogGunnerHelmet1a'
	LandGrunt=Sound'MaleSounds.(All).land10'
	ClassIcon=Texture'SG_Hud.COG.sg_classicons_hgunner'
	RequiredEquipment[0]="WarClassHeavy.WeapCOGMinigun"
	RequiredEquipment[1]="WarClassHeavy.WarCogHeavyArmor"
	GroundSpeed=300
	WaterSpeed=300
	AirSpeed=300
	JumpZ=450
	CrouchHeight=77
	CrouchRadius=35
	MenuName="COG Heavy"
	Mesh=SkeletalMesh'COGHeavySoldiers.COGGunnerMesh'
	LODBias=4
}