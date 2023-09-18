//=============================================================================
// WarfarePawn:  base class of Warfare pawns which use MoCap animation
//=============================================================================

class WarfarePawn extends UnrealPawn;

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Male\gib01.WAV" NAME="NewGib" GROUP="Male"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Generic\Resp2a.wav" NAME="Resp2A" GROUP="General"
#exec OBJ LOAD FILE=..\StaticMeshes\character_helmetmeshes.usx PACKAGE=character_helmetmeshes
#exec OBJ LOAD FILE=..\Textures\sg_Hud.utx PACKAGE=SG_Hud
#exec OBJ LOAD FILE=..\Sounds\WarfareSteps.uax PACKAGE=WarfareSteps
#exec OBJ LOAD FILE=..\Sounds\MaleSounds.uax

const RESTINGPOSECHANNEL = 0;
const FALLINGCHANNEL = 1;
// 10 channels used by movement
const AIMCHANNEL = 12;
const TAKEHITCHANNEL = 13;
const FIRINGCHANNEL = 14;
const FIRINGBLENDBONE = 'lower_back';

var() staticmesh Helmet;
var class<HelmetAttachment> HelmetClass;
var HelmetAttachment HelmetActor;
var name HelmetBone;
var name EyeBone;
var vector HelmetRelativeLocation;
var rotator HelmetRelativeRotation;
var name LastHitAnim;
var vector SmoothedEyeDiff;
var float DeathStart;

var sound	HitSound[4];
var	sound	Land;
var(Sounds) sound	GibSounds[4];
var(Sounds) sound	UWHit[2];
var(Sounds)	sound	Deaths[6];

var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	GaspSound;
var(Sounds) sound	LandGrunt;
var(Sounds) sound	JumpSound;
var(Sounds) sound	Footstep[4];
var(Sounds) sound	WaterStep;


// FIXME - weapon change == ChangeAnimation();

// These values are used specificlly by the COG heavy gunner class to perform
// lock ons.  

var bool bLocked;
var bool bSeeking;
var float LockXMod[3];
var float LastSeekTime;

// ViewKickAdjustment and ViewKickRate - Used to kick the view around for weapons and damage

var vector ViewKickAdjustment, ViewKickRate, ViewKickMax;
var float KickDelay;			

var array<Influence> Influences;
var() float Energy;						// Holds their special charge
var() material ClassIcon;				// Holds the class icon

var array<Constructions> MyConstructions;
var Constructions SelectedConstruction; // Points to the currently selected construction

var int LastFootStepIndex;	

var ShadowProjector_WarfareGame	Shadow; // Modified:  Sean C. Dumas/Taldren

var float PatrolPct;

replication
{
	reliable if (ROLE==ROLE_Authority)
		ClientKickView;

	reliable if (Role<ROLE_Authority)
		SpecialSkill,NextSkill,PrevSkill;
		
	reliable if (ROLE==ROLE_Authority)
		Energy;

	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		 SelectedConstruction;
	
}

function Reset()
{
	if ( HelmetActor != None )
		HelmetActor.Destroy();
	Super.Reset();
}

// Allow each class to draw something to the hud if needed
simulated function DrawWarfareHud(canvas Canvas, WarfareHud Hud, FontInfo Fonts, float Scale)
{
	local string s;
	local float xl,yl;

	local float cx,cy;
	local Vector View,x,y,z;
	local PlayerController P;
	local Beacons B;
	
	// Draw the hud Icon

	DrawClassIcon(Canvas, Scale, Canvas.ClipX - (123*Scale) - (48*Scale), (127 * Scale) - (48*Scale));
	
	// Draw this pawn's current energy
	
	s = "Energy: "$int(Energy);
	
	Canvas.Font = Canvas.smallfont;
	Canvas.StrLen(s,xl,yl);
	Canvas.SetPos(Canvas.ClipX -xl - 5,Canvas.ClipY-yl-5);
	Canvas.DrawText(s,false);

	// Draw any beacons

	P = PlayerController(Controller);
	if (P==None)
		return;

	foreach DynamicActors(class'Beacons',b)
	{
		if (B.bEnabled)
		{
			GetAxes(GetViewRotation(), X, Y, Z);
			View = B.Location - Location - (EyeHeight * vect(0,0,1));
			if ( ( (View Dot X) > 0.70 ) && (B.Team == PlayerReplicationInfo.Team.TeamIndex) )	// In front and of this team
			{			
				// Draw the symbol
			
				cX = (Canvas.ClipX / 2) + ((View Dot Y)) * ((Canvas.ClipX / 2) / tan(P.FOVAngle * Pi / 360)) / (View Dot X);
				cY = (Canvas.ClipY / 2) + (-(View Dot Z)) * ((Canvas.ClipX / 2) / tan(P.FOVAngle * Pi / 360)) / (View Dot X);

				DrawBeacon(B,Canvas,Hud,cx,cy);
			}
		}	
	}

	DrawConstruction(Canvas, Hud, Scale);
	
}

simulated function DrawConstruction(Canvas C, WarfareHud H, Float Scale)
{
	local float xl,yl;

	
	if ( (SelectedConstruction!=None) && (SelectedConstruction.StatusIcon!=None) )
	{
		// Have the Construction Update if Needed
		
		SelectedConstruction.Update(H.CurrentDeltaTime);

		C.SetDrawColor(255,255,0);
		C.SetPos(SelectedConstruction.XPos, C.ClipY-4-(64*Scale));
		C.DrawTile(SelectedConstruction.StatusIcon,64*Scale,64*Scale,0,0,64,64);
		C.SetPos(8+64*Scale,C.ClipY-(64*Scale));
		C.Font = H.SmallFont;
		C.DrawText(SelectedConstruction.ConstructionMessage);
		C.StrLen("#",xl,yl);
		C.SetPos(8+64*Scale,C.ClipY-(64*Scale)+yl+2);
		C.Font = H.MedFont;
		C.DrawText(SelectedConstruction.ItemName);
	}

}

// DrawBeacon allows us to screen for certain becaons

simulated function DrawBeacon(Beacons B, Canvas C, WarfareHud H,  float X, float Y)
{

	if (MedicBeacon(b)!=None)	// Class Specific
		return;
		
	if (RepairBeacon(B)!=None)	// Class Specific
		return;

	B.DrawBeacon(Self,C,H,X,Y);
}		
		

function PlayDyingSound()
{
	if ( HeadVolume.bWaterVolume )
	{
		PlaySound(UWHit[Rand(2)], SLOT_Pain,1,,,Frand()*0.2+0.9);
		return;
	}
	PlaySound(Deaths[Rand(6)], SLOT_Pain, 1);
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
 	local UTTeleportEffect PTE; 

	if ( IsHumanControlled() )
		PlayerController(Controller).SetFOVAngle(135);
	if ( bSound )
	{
 		PTE = Spawn(class'UTTeleportEffect');
 		PTE.Initialize(self, bOut);
		PlaySound(sound'Resp2A',, 10.0);
	}
}

function SpecialSkill()
{
	if (SelectedConstruction != None)
		SelectedConstruction.Use(0);
}

function PrevSkill()
{
	local int index;

	if (SelectedConstruction!=None)
	{
		Index = FindIndexForConstruction(SelectedConstruction) - 1;
		if (Index<0)
			Index = MyConstructions.Length-1;	
		
		SelectedConstruction.Prev(MyConstructions[Index]);
		return;
	}	

	if( WarfareWeapon(Weapon)!=None )
		WarfareWeapon(Weapon).PrevWeaponFunction();
}

function NextSkill()
{
	local int index;

	if (SelectedConstruction!=None)
	{
	
		Index = FindIndexForConstruction(SelectedConstruction) + 1;
		if (Index>=MyConstructions.Length)
			Index = 0;	
		
		SelectedConstruction.Next(MyConstructions[Index]);
		return;
	}
		
	if( WarfareWeapon(Weapon) != None )
		WarfareWeapon(Weapon).NextWeaponFunction();
}


function AddInfluence(string InfluenceName)
{

	local Influence NewInfluence;
	local class<Influence> NewInfluenceClass;
	
	NewInfluenceClass = class<Influence>(DynamicLoadObject(InfluenceName, class'Class'));

	if (NewInfluenceClass==None)
	{
		log("Unable to load "$InfluenceName);
		return;
	}

	NewInfluence=  Spawn(NewInfluenceClass,Self,,Location,Rotation);
	if (NewInfluence==None)
	{
		log("Unable to spawn "$InfluenceName$" (class="$NewInfluenceClass$")");
		return;
	}

	// Add to the array
	
	Influences.Length = Influences.Length + 1;
	Influences[Influences.Length-1] = NewInfluence;

}

// Clean up the Influences

simulated event Destroyed()
{
	local int i;
	
	if(Role == ROLE_Authority)
	{
		for (i=0;i<Influences.Length;i++)
			Influences[i].Destroy();
		if ( HelmetActor != None )
			HelmetActor.Destroy();
	}

	if ( Shadow != None )
		Shadow.Destroy();

	Super.Destroyed();
}

simulated function ClientKickView(vector Kick)
{
	local vector deltaKick;
	local vector OldKick;
	local rotator VR;

	OldKick = ViewKickAdjustment;
	
	ViewKickAdjustment.X = Clamp(ViewKickAdjustment.X + Kick.X, ViewKickMax.X*-1, ViewKickMax.X);		// Yaw
	
	if (Kick.Y!=0)
	{
		if (frand()>0.5)
			Kick.Y *= -1;
	}
	
	ViewKickAdjustment.Y = Clamp(ViewKickAdjustment.Y + Kick.Y, ViewKickMax.Z*-1, ViewKickMax.Z);		// Roll 	
	ViewKickAdjustment.Z = Clamp(ViewKickAdjustment.Z + Kick.Z, ViewKickMax.Z*-1, ViewKickMax.Z);		// Pitch 	

	DeltaKick = ViewKickAdjustment - OldKick;

	if (PlayerController(Controller)!=None)
	{
		vr = Controller.Rotation;
		vr.yaw += DeltaKick.x;
		vr.roll += DeltaKick.y;
		vr.pitch += DeltaKick.z;
		Controller.SetRotation(vr);
	}			
	
}


simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);

	Canvas.DrawText("ViewKickAdjustment: "$ViewKickAdjustment);
	YPos += YL;
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local PlayerController PC;
	local float DamagePct;
	local int OrigHealth;
	local vector KickAdjust;

	OrigHealth = Health;

	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

	if (Health>=OrigHealth)
		return;
		
	// Flash the screen
	
	PC = PlayerController(Controller);
	
	if (PC!=None)
	{
		PC.FlashScale=vect(1.5,0,0);
		PC.FlashFog=vect(255,0,0);
	}

	if ( ClassIsChildOf(damageType, class 'WarfareDamageType') )
	{

		DamagePct = (OrigHealth - Health) / Damage;
		CalcHitAdjust(DamagePct, damageType, HitLocation, KickAdjust);
		ClientKickView(KickAdjust);

		// Ignore roll for now	
	}
	
	// If health < 20, automatically call for help
	
	if ( ( (OrigHealth>20) && (Health<20) ) && (WarfarePlayer(Controller)!=None) )
		WarfarePlayer(Controller).ServerCallForHelp();
	
}

// Lame attempt at locational damage.  Calculates the rotational adjustments based on where you are hit and the % of the full
// damage you receive.

function CalcHitAdjust(int DamagePct, class<DamageType> damageType, vector HitLoc, out vector KickAdjust)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotx, doty;
	
	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;

	dotx = HitVec2D dot X;
	doty = HitVec dot Y;

	// Check for an upper body shot

	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight )
	{	
		if (dotx> 0.31) 	// Front side of body
		{
			KickAdjust.Z = damageType.default.DamageKick.Z * DamagePct;
		}
		else if (dotx < -0.31)	// Back side of body
		{
			KickAdjust.Z = (damageType.default.DamageKick.Z * DamagePct) * -1; 
		}
		else
			KickAdjust.Z = 0;
	}
	else	// Lower shot
	{	
		if (dotx> 0.31) 	// Front side of body
		{
			KickAdjust.Z = (damageType.default.DamageKick.Z * DamagePct) * -1;
		}
		else if (dotx < -0.31)
		{
			KickAdjust.Z = damageType.default.DamageKick.Z * DamagePct;
		}
		else
			KickAdjust.Z = 0;
	}

	// Process Left/Right
	
	if (doty > 0.0)
	{
		KickAdjust.X = damageType.default.DamageKick.X;
	}
	else
	{
		KickAdjust.X = (damageType.default.DamageKick.X)*-1;
	}

	KickADjust.Y = 0;	// Never roll

}

function float MovetoZero(float step, float Value)
{
	if (Value<0)
	{
		Value += Step;
		if (Value<0)
			return Value;
		else
			return 0;
	}
	else if (Value>0)
	{
		Value -= Step;
		if (Value>0)
			return Value;
		else
			return 0;
	}
}	

function RestoreViews(float Delta)
{
	local vector OldKick, DeltaKick;
	local rotator VR;
	
	if ( ViewKickAdjustment == vect(0,0,0) )
		return;

	OldKick = ViewKickAdjustment;		
		
	ViewKickAdjustment.X = MoveToZero(ViewKickRate.X * Delta, ViewKickAdjustment.X);		
	ViewKickAdjustment.Y = MoveToZero(ViewKickRate.Y * Delta, ViewKickAdjustment.Y);		
	ViewKickAdjustment.Z = MoveToZero(ViewKickRate.Z * Delta, ViewKickAdjustment.Z);		

	DeltaKick = OldKick - ViewKickAdjustment;
	if (PlayerController(Controller)!=None)
	{
		vr = Controller.Rotation;
		vr.yaw -= DeltaKick.x;
		vr.roll -= DeltaKick.y;
		vr.pitch -= DeltaKick.z;
		Controller.SetRotation(vr);
	}			

}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetHelmet();
}

simulated function PostNetBeginPlay()
{
	if(bActorShadows)
	{
 		Shadow = Spawn(class'ShadowProjector_WarfareGame',None,'',Location); // Modified:  Sean C. Dumas/Taldren
		Shadow.ShadowActor = self;
		Shadow.LightDirection = Normal(vect(1,1,3));
		Shadow.LightDistance = 380;
		Shadow.MaxTraceDistance = 350;
		Shadow.UpdateShadow();
	}
}

function SetHelmet()
{

	if ( HelmetActor == None )
	{
		HelmetActor = Spawn(HelmetClass,Owner);
		HelmetActor.SetDrawScale(HelmetActor.DrawScale * DrawScale);
	}
	
	HelmetActor.SetStaticMesh(Helmet);
	AttachToBone(HelmetActor,HelmetBone);
	HelmetActor.SetRelativeLocation(HelmetRelativeLocation);
	HelmetActor.SetRelativeRotation(HelmetRelativeRotation);

}

//-----------------------------------------------------------------------------
// Animation Notify functions
simulated function FootStepping(int side)
{
	local int Index;
	if ( TouchingWaterVolume() )
		PlaySound(WaterStep, SLOT_Interact, 1, false, 75.0, 1.0);
	else
	{
		Index = Rand(4);
		if (Index==LastFootStepIndex)
			Index = (Index+1) % 4;
					
		LastFootStepIndex = Index;
		PlaySound(FootStep[Index], SLOT_Interact, 1, false, 75.0, 1.0);
	}
}

// Notify called when ready to land (should loop)
function CheckLanding()
{
	if ( Physics == PHYS_Falling )
	{
		// stop animating, haven't landed yet
		TweenAnim('Land', 9000.0);
	}
}

//-----------------------------------------------------------------------------
// Animation functions

simulated event AnimEnd(int Channel)
{
	if ( Channel == 0 )
		PlayWaiting();
	else if ( Channel == FIRINGCHANNEL )
	{

		// FIRINGCHANNEL used for upper body (firing weapons, etc.)
		if ( !bSteadyFiring )
			AnimBlendToAlpha(FIRINGCHANNEL,0,0.05);
	}
	else if ( Channel == TAKEHITCHANNEL )
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
	else if ( Channel == FALLINGCHANNEL )
	{
		if ( Physics != PHYS_Falling )
		{
			AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
			PlayWaiting();
		}
		else
			PlayFalling();
	}
}

simulated event ChangeAnimation()
{
	if ( (Controller != None) && Controller.bControlAnimations )
		return;
	// player animation - set up new idle and moving animations
	PlayWaiting();
	PlayMoving();
}

//-----------------------------------------------------------------------------
// Player Animation functions

simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	if ( FRand() < 0.8 )
		PlayAnim('death_neck',1.0,0.15);
	else
		PlayAnim('death_fire',1.0,0.15);
}

function CheckHelmetHit(class<DamageType> DamageType, int Damage)
{
	if ( Helmet == None )
		return;

	if (  Damage > 60 )
		KnockOffHelmet();
}

function KnockOffHelmet()
{
	HelmetActor.TornOff();
	HelmetActor = None;
}

// spawn gibs (local, not replicated)
simulated function SpawnGibs(Rotator HitRotation, class<DamageType> D)
{
	local Blood b;

	// FIXME - use particle system!
	PlaySound(GibSounds[Rand(4)], SLOT_Misc, 1);

	b = Spawn(class 'Blood',,,,rot(16384,0,0));
	b.RemoteRole = ROLE_None;
}

simulated function vector EyePosition()
{
/*	local vector EyePos;

	if ( bPlayedDeath )
	{
		EyePos = GetBoneCoords(EyeBone).Origin;
		if ( Level.TimeSeconds - DeathStart < 0.1 )
			EyePos = EyePos + SmoothedEyeDiff * (1 - 10*(Level.TimeSeconds-DeathStart));
		return EyePos + WalkBob;
	}
	else
*/		return EyeHeight * vect(0,0,1) + WalkBob;
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	// Do most of the dying stuff (tear off, ragoll etc.)
	Super.PlayDying(DamageType, HitLoc);

	// Possibly throw off helmet
	CheckHelmetHit(DamageType,100);

//	SmoothedEyeDiff = EyePosition() - GetBoneCoords(EyeBone).Origin;
	//bPlayedDeath = true;
	//DeathStart = Level.TimeSeconds;

	/*
	if ( bPhysicsAnimUpdate )
	{
		bTearOff = true;
		bReplicateMovement = false;
		HitDamageType = DamageType;
		TakeHitLocation = HitLoc;
		if ( (HitDamageType != None) && (HitDamageType.default.GibModifier >= 100) )
			ChunkUp(Rotation, DamageType);
	}
	*/

	/* UWRAGDOLL
	if ( (Level.NetMode != NM_DedicatedServer) && (KPhysics != '') )
	{
		bPhysicsAnimUpdate = false;
		SetPhysics(PHYS_KarmaRagDoll);
		KAddImpulse(TearOffMomentum, TakeHitLocation);
	}
	else
	*/

	/*
		Velocity += TearOffMomentum;
		SetPhysics(PHYS_Falling);
	*/

	// If we are not in ragdoll for whatever reason, turn off gameplay animations and play a dying animation
	if ( Physics != PHYS_KarmaRagDoll )
	{
		AnimBlendToAlpha(FIRINGCHANNEL,0,0.1);
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
		AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
		PlayDyingAnim(DamageType,HitLoc);
	}

	//GotoState('Dying');
}

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	Super.PlayHit(Damage, InstigatedBy,HitLocation, damageType,Momentum);

	if ( Health > 0 )
		return;
		
	StopAnimating();
}
			
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local vector X,Y,Z,Dir;
	local name HitAnim;
	local float MyPitch;

	Super.PlayTakeHit(HitLoc,Damage,damageType);
	CheckHelmetHit(DamageType,Damage);
	GetAxes(Rotation,X,Y,Z);

	Dir = Normal(HitLoc - Location);
	
	AnimBlendParams(TAKEHITCHANNEL,1);
	if ( (Dir Dot X) < 0 )
		HitAnim = 'hit_back';
	else if ( ((Dir Dot X) > 0.9) || (HitLoc.Z < Location.Z) )
		HitAnim = 'hit_chest';
	else if ( (Dir Dot Y) > 0 )
		HitAnim = 'Hit_Left';
	else
		HitAnim = 'Hit_Right';
	if ( LastHitAnim == HitAnim )
	{
		if ( HitAnim == 'Hit_Chest' )
			HitAnim = 'Hit_Back';
		else
			HitAnim = 'Hit_Chest';
	}
	
	LastHitAnim = HitAnim;
	if ( HasAnim(HitAnim) ) // FIXME TEMP
		SetAnimAction(HitAnim);

	if ( Level.TimeSeconds - LastPainSound < 0.3 )
		return;

	if (HitSound[0] == None)
		return;
	LastPainSound = Level.TimeSeconds;
	MyPitch = FRand() * 0.15 + 0.9;
	if ( HeadVolume.bWaterVolume )
	{
		if ( damageType.IsA('Drowned') )
			PlayOwnedSound(drown, SLOT_Pain);
		else
			PlayOwnedSound(UWHit[Rand(2)], SLOT_Pain,1.0,,,MyPitch);
		return;
	}
	else
	{
		PlaySound(HitSound[rand(4)], SLOT_Pain,1.0,,,MyPitch);
	}
	
}

/*
FIXME - blend up/down
FIXME - clamp based on rotation of bone below neck
FIXME - use head rotation for movement dir, and if start moving, turn body to face movement dir
* Animation sequence run_lookup   19  Tracktime: 36.000000 rate: 60.000000 
	  First raw frame  3357  total raw frames 36  group: [None]

 * Animation sequence run_lookdown   20  Tracktime: 36.000000 rate: 60.000000 
	  First raw frame  3393  total raw frames 36  group: [None]


simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	local int TurnRate; 
	local rotator NeckRot;

	//if ( Physics == PHYS_Ladder )
	// don't turn body

	NeckRot = GetBoneRotation('neck');
	NeckRot.Yaw = NewRotation.Yaw - 16384;
	NeckRot.Pitch = Clamp(NewRotation.Pitch & 65535, -8192, 8192);;
	SetBoneDirection( 'neck', NeckRot);
	if ( abs(NewRotation.Yaw - Rotation.Yaw) > 8192 )
		bTurningBody = true;

	if ( bTurningBody )
	{
		TurnRate = 32768 * DeltaTime;
		if ( abs(NewRotation.Yaw - Rotation.Yaw) < TurnRate )
		{
			SetRotation(NewRotation);
			bTurningBody = false;
		}
		else 
		{
			if ( abs(NewRotation.Yaw - Rotation.Yaw) > 14000 )
				TurnRate = Max(TurnRate, abs(NewRotation.Yaw - Rotation.Yaw) - 14000);
				NewRotation.Yaw = Rotation.Yaw + TurnRate;
			if ( Rotation.Yaw ClockwiseFrom NewRotation.Yaw )
			else
				NewRotation.Yaw = Rotation.Yaw - TurnRate;
			SetRotation(NewRotation);
		}
	}
}
*/

simulated event PlayFalling()
{
	local name OldAnim;
	local float frame,rate;

	GetAnimParams(0,OldAnim,frame,rate);

	if ( (OldAnim=='Jump_run') || (OldAnim=='Jump_stand') )
		return;

	PlayJump();
}

simulated event PlayJump()
{
	PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );

	if ( CurrentDir == DCLICK_Left )
		PlayAnim('Dodge_right', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else if ( CurrentDir == DCLICK_Right )
		PlayAnim('Dodge_left', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else if ( CurrentDir == DCLICK_Back )
		PlayAnim('DodgeB', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else if ( CurrentDir == DCLICK_Forward )
		PlayAnim('Dodge_forward', FMax(0.35, PhysicsVolume.Gravity.Z/PhysicsVolume.Default.Gravity.Z), 0.06);
	else
	{
		BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
		if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
			PlayAnim('Jump_run');
		else
			PlayAnim('Jump_stand'); 
	}

	CurrentDir = DCLICK_None;
}

function PlayLanded(float impactVel)
{	
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,384,FRand()*0.4+0.8);	// 1200
	if ( (impactVel > 0.01) && !TouchingWaterVolume() )
		PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,256, 1.0);	// 1000
}

simulated event PlayLandingAnimation(float ImpactVel)
{
	if ( (impactVel > 0.06) || IsAnimating(FALLINGCHANNEL) ) 
	{
		PlayWaiting();
	}
	else if ( !IsAnimating(0) )
		PlayWaiting();
}

/* 
Animation channel FIRINGCHANNEL used for firing / combat blending
*/
simulated event StopPlayFiring()
{
	if ( bSteadyFiring )
	{
		// FIXME - smooth blend out firing
		bSteadyFiring = false;
		AnimBlendToAlpha(FIRINGCHANNEL,0,0.1);
		PlayWaiting();
	}
}
	
simulated function PlayFiring(float Rate, name FiringMode)
{
	if ( bIgnorePlayFiring )
		return;

//	AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE);

	// choose anim based on weapon's mode
	// play full anim in the 0 (standing) channel
	// fixme - not using shoot_burst
	
	if ( FiringMode == 'MODE_Grenade' )
	{
		if ( (Physics == PHYS_Walking) && !bIsCrouched )
			PlayAnim('shoot_gernade',Rate,0.05);
		else
			PlayAnim('shoot_gernade',Rate,0.05,FIRINGCHANNEL);
	}
	else if (FiringMode == 'MODE_Burst')
	{
		if ( (Physics == PHYS_Walking) && !bIsCrouched )
		{
			if (Velocity==vect(0,0,0))
			{
				
				PlayAnim('shoot_burst',(Rate*1.1),0.00);
//				PlayAnim('shoot_burst',(Rate*1.1),0.00,FIRINGCHANNEL);
				AnimBlendToAlpha(FIRINGCHANNEL,1.0,0.05);
				return;
			}
			PlayAnim('shoot_burst',(Rate*1.1),0.05,FIRINGCHANNEL);
		}
		else
			PlayAnim('shoot_burst',(Rate*1.1),0.05,FIRINGCHANNEL);

		AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE,true);
	}
	else if ( bSteadyFiring )
	{
		AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE,true);
	
//		if ( (Physics == PHYS_Walking) && !bIsCrouched )
//			LoopAnim('shoot_auto',Rate,0.05);
//		else
			LoopAnim('shoot_auto',Rate,0.05,FIRINGCHANNEL);
	}
	else
	{
		AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE,true);
	
		if ( (Physics == PHYS_Walking) && Velocity==vect(0,0,0) && !bIsCrouched )
			PlayAnim('shoot_single',Rate,0.05);
			
//		if ( (Physics == PHYS_Walking) && !bIsCrouched )
//			PlayAnim('shoot_single',Rate,0.05);
//		else
			PlayAnim('shoot_single',Rate,0.00,FIRINGCHANNEL);
	}
}

simulated function PlayWaiting()
{
	if ( KVehicle(Base) != None )
		AnimateRiding();
	else if ( Physics == PHYS_Swimming )
		AnimateTreading();
	else if ( Physics == PHYS_Flying )
		AnimateFlying();
	else if ( Physics == PHYS_Ladder )
		AnimateStoppedOnLadder();
	else if ( Physics == PHYS_Falling )
	{
		if ( !IsAnimating(FALLINGCHANNEL) )
			PlayFalling();
	}
	else if ( bIsCrouched )
		AnimateCrouching();
	else if ( bSteadyFiring )
		PlayFiring(1.0,'');
	else
		AnimateStanding();
}

simulated function PlayMoving()
{
	if ( (Physics == PHYS_None) 
		|| ((Controller != None) && Controller.bPreparingMove) )
	{
		// bot is preparing move - not really moving 
		PlayWaiting();
		return;
	}
	if ( Physics == PHYS_Walking )
	{
		if ( bIsCrouched )
			AnimateCrouchWalking();
		else if ( bIsWalking )
			AnimateWalking();
		else
			AnimateRunning();
	}
	else if ( (Physics == PHYS_Swimming)
		|| ((Physics == PHYS_Falling) && IsPlayingSwimming() && TouchingWaterVolume()) )
		AnimateSwimming();
	else if ( Physics == PHYS_Ladder )
		AnimateClimbing();
	else if ( Physics == PHYS_Flying )
		AnimateFlying();
	else
	{
		if ( bIsCrouched )
			AnimateCrouchWalking();
		else if ( bIsWalking )
			AnimateWalking();
		else
			AnimateRunning();
	}
}

/* LoopIfNeeded()
play looping idle animation only if not already animating
*/
simulated function LoopIfNeeded(name NewAnim, float NewRate, float BlendIn)
{
	local name OldAnim;
	local float frame,rate;

	GetAnimParams(0,OldAnim,frame,rate);

	// FIXME - get tween time from anim
	if ( (NewAnim != OldAnim) || (NewRate != Rate) || !IsAnimating(0) )
		LoopAnim(NewAnim, NewRate, BlendIn);
	else
		LoopAnim(NewAnim, NewRate);
}
//************************************************************************************
// Private animation functions

// Current assumptions
// 
// all swimming and treading water anims should belong to the group SWIMMING
// all running anims should belong to the group RUNNING

simulated function bool IsPlayingSwimming()
{
	return AnimIsInGroup(0,'SWIMMING');
}

/* AnimateSwimming()
Moving through water - check acceleration for direction
*/
simulated function AnimateSwimming()
{
	MovementAnims[0] = 'Swim';
	MovementAnims[1] = 'Swim';
	MovementAnims[2] = 'Swim';
	MovementAnims[3] = 'Swim';
}

/* AnimateTreading()
Still in water
*/
simulated function AnimateTreading()
{
	MovementAnims[0] = 'Swim';
	MovementAnims[1] = 'Swim';
	MovementAnims[2] = 'Swim';
	MovementAnims[3] = 'Swim';
}

/* AnimateCrouchWalking()
crouching and walking
*/
simulated function AnimateCrouchWalking()
{
	TurnLeftAnim = 'crouch_backpeddle';
	TurnRightAnim = 'crouch_backpeddle';
	MovementAnims[0] = 'Crouch_Walk';
	MovementAnims[2] = 'Crouch_Walk_left';
	MovementAnims[1] = 'crouch_backpeddle';
	MovementAnims[3] = 'Crouch_Walk_right';
}

simulated function AnimateWalking()
{
	TurnLeftAnim = 'turn_left';
	TurnRightAnim = 'turn_right';
	WalkingPct = Default.WalkingPct;
	MovementAnims[0] = 'Walk';
	MovementAnims[2] = 'walk_strafe_left';
	MovementAnims[1] = 'walk_backpeddle';
	MovementAnims[3] = 'walk_strafe_right';
}

/* AnimateClimbing()
climbing
*/
simulated function AnimateClimbing()
{
	local name NewAnim;
	local int i;

	if ( (OnLadder == None) || (OnLadder.ClimbingAnimation == '') )
		NewAnim = 'Ladder_Climb'; 
	else
		NewAnim = OnLadder.ClimbingAnimation;
	for ( i=0; i<4; i++ )
		MovementAnims[i] = NewAnim;
	TurnLeftAnim = NewAnim;
	TurnRightAnim = NewAnim;
}

simulated function AnimateStoppedOnLadder()
{
	local name NewAnim;

	if ( (OnLadder == None) || (OnLadder.ClimbingAnimation == '') )
		NewAnim = 'Ladder_Climb'; 
	else
		NewAnim = OnLadder.ClimbingAnimation;
	TweenAnim(NewAnim, 1.0); // FIXME TEMP - need paused on ladder animation
}

/* AnimateFlying()
flying - not used in Warfare, so don't need real animation
*/
simulated function AnimateFlying()
{
	AnimateSwimming();
}

simulated function AnimateRiding()
{
}

simulated function AnimateStanding()
{
	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
	{
		// FIXME - play chatting animation
		return;
	}
	LoopIfNeeded('Stand_Rdy',1.0,0.1);
}

simulated function AnimateCrouching()
{
	LoopIfNeeded('Crouch',1.0,0.25);
}
	
simulated function AnimateRunning()
{


//	if ( Weapon == None )
//		MovementAnims[0] = 'Run_relaxed';
//	else if ( Weapon.bPointing )
//		MovementAnims[0] = 'Run';
//	else 
	MovementAnims[0] = 'Run';
	TurnLeftAnim = 'turn_left';
	TurnRightAnim = 'turn_right';
	MovementAnims[2] = 'Run_Left';
	MovementAnims[1] = 'Run_Back';
	MovementAnims[3] = 'Run_Right';
	
}

simulated function DrawClassIcon(canvas Canvas, float scale, float X, float Y)
{
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(x,y);
	if (ClassIcon!=None)
		Canvas.DrawTile(ClassIcon,96*scale,96*scale,0,0,128,128);
}

function Gasp()
{
	if ( Role != ROLE_Authority )
		return;
	if ( BreathTime < 2 )
		PlaySound(GaspSound, SLOT_Talk, 2.0);
	else
		PlaySound(BreathAgain, SLOT_Talk, 2.0);
}

function int FindIndexForConstruction(constructions C)
{
	local int i;
	for (i=0;i<MyConstructions.Length;i++)
	{
		if (MyConstructions[i] == C)
			return i;
	}
	
	return -1;
}
	

function AddConstruction(constructions C)
{
	MyConstructions.Length = MyConstructions.Length+1;
	MyConstructions[MyConstructions.Length-1] = C;
	
	if (SelectedConstruction == None)
		SelectedConstruction = C;
	
}

function RemoveConstruction(constructions C)
{
	local int i;
	
	i = FindIndexForConstruction(C);
	if (i>=0)
		MyConstructions.Remove(I,1);
	else
		log("Attempt to remove a construction that has no index");
}

defaultproperties
{
	Helmet=StaticMesh'character_helmetmeshes.cog_helmets.COGGruntHelmet1a'
	HelmetClass=Class'HelmetAttachment'
	HelmetBone=Head
	EyeBone=Head
	HelmetRelativeLocation=(X=0,Y=-0.6,Z=0)
	HelmetRelativeRotation=(Pitch=0,Yaw=0,Roll=49152)
	HitSound[0]=Sound'MaleSounds.(All).injurL2'
	HitSound[1]=Sound'MaleSounds.(All).injurL04'
	HitSound[2]=Sound'MaleSounds.(All).injurM04'
	HitSound[3]=Sound'MaleSounds.(All).injurH5'
	Land=Sound'WarEffects.Generic.Land1'
	GibSounds[0]=Sound'WarEffects.Gibs.Gib1'
	GibSounds[1]=Sound'Male.NewGib'
	GibSounds[2]=Sound'WarEffects.Gibs.Gib4'
	GibSounds[3]=Sound'WarEffects.Gibs.Gib5'
	UWHit[0]=Sound'MaleSounds.(All).UWinjur41'
	UWHit[1]=Sound'MaleSounds.(All).UWinjur42'
	Deaths[0]=Sound'MaleSounds.(All).deathc1'
	Deaths[1]=Sound'MaleSounds.(All).deathc51'
	Deaths[2]=Sound'MaleSounds.(All).deathc3'
	Deaths[3]=Sound'MaleSounds.(All).deathc4'
	Deaths[4]=Sound'MaleSounds.(All).deathc53'
	Deaths[5]=Sound'MaleSounds.(All).deathc53'
	drown=Sound'MaleSounds.(All).drownM02'
	breathagain=Sound'MaleSounds.(All).gasp02'
	GaspSound=Sound'MaleSounds.(All).hgasp1'
	LandGrunt=Sound'MaleSounds.(All).land01'
	JumpSound=Sound'MaleSounds.(All).jump1'
	Footstep[0]=Sound'WarfareSteps.Gravel.footstep_gravel01'
	Footstep[1]=Sound'WarfareSteps.Gravel.footstep_gravel02'
	Footstep[2]=Sound'WarfareSteps.Gravel.footstep_gravel03'
	Footstep[3]=Sound'WarfareSteps.Gravel.footstep_gravel04'
	WaterStep=Sound'WarEffects.Generic.LSplash'
	ViewKickRate=(X=2048,Y=2048,Z=2048)
	ViewKickMax=(X=16384,Y=2048,Z=2048)
	Energy=100
	ClassIcon=Texture'SG_Hud.COG.sg_classicons_soldier'
	PatrolPct=0.2
	LoadOut=1
	VoiceType="WarClassLight.VoiceMaleTwo"
	GroundSpeed=375
	WaterSpeed=175
	AirSpeed=375
	WalkingPct=0.65
	BloodEffect=Class'WarEffects.BloodHit'
	LowGoreBlood=Class'WarEffects.GreenBlood'
	bPhysicsAnimUpdate=true
	MovementAnims[0]=Run
	MovementAnims[1]=Run_Back
	MovementAnims[2]=Run_Left
	MovementAnims[3]=Run_Right
	TurnLeftAnim=turn_left
	TurnRightAnim=turn_right
	BackwardStrafeBias=0.5
}