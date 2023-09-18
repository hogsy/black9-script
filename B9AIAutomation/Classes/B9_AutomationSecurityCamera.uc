//=============================================================================
// B9_AutomationSecurityCamera
//
// 
//	Sentry Turret
// 
//=============================================================================
class B9_AutomationSecurityCamera extends B9_Automation;

#exec OBJ LOAD FILE=..\textures\Luna_Hanger_Tex_HD.utx PACKAGE=Luna_Hanger_Tex_HD

var (Camera) float	fTimeToIDPlayer; // In seconds
var (Camera) int	fRight;
var (Camera) int	fLeft;
var (Camera) int	fYawRate;
var (Camera) int	fCameraPitch;
var (Camera) float	fViewDistance;
var int				fViewAngle;

var string fLocksKeyCode;


var material fGreenLightMaterial;
var material fAmberLightMaterial;
var material fRedLightMaterial;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	fGunPart.CopyMaterialsToSkins();
	SetCollisionSize(40.0f, 40.0f);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	Health -= Damage;

	if (Health <= 0)
	{
		Explode(HitLocation, Normal(HitLocation-instigatedBy.Location));
	}
}

function SetGreenLight()
{
	//Log("GREEN LIGHT");
	fGunPart.Skins[0]=fGreenLightMaterial;
}

function SetAmberLight()
{
	//Log("AMBER LIGHT");
	fGunPart.Skins[0]=fAmberLightMaterial;
}

function SetRedLight()
{
	//Log("RED LIGHT");
	fGunPart.Skins[0]=fRedLightMaterial;
}

simulated function OrientV( vector v, optional float Delta )
{
	local rotator newrot;
	local rotator partrot;
	
	// Note: camera never uses RotationRate (Delta parameter ignored).

	newrot = rotator(v >> (newrot - Rotation));

	// The Shaft can yaw
	partRot.Yaw		= newrot.Yaw;
	partRot.Pitch	= 0;
	partRot.Roll	= 0;
	fShaftPart.SetRelativeRotation( partRot );

	// The camera has a set pitch
	partRot.Yaw		= 0;
	partRot.Pitch	= fCameraPitch;
	partRot.Roll	= 0;
	fGunPart.SetRelativeRotation( partRot );
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'ExplosionFX_One',,,HitLocation,rot(16384,0,0));
	}
 	Destroy();
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fTimeToIDPlayer=2
	fRight=10000
	fLeft=-10000
	fYawRate=5000
	fViewDistance=10000
	fViewAngle=8192
	fLocksKeyCode="ududu"
	fGreenLightMaterial=Shader'Luna_Hanger_Tex_HD.new_camera.green_shader'
	fAmberLightMaterial=Shader'Luna_Hanger_Tex_HD.new_camera.yellow_shader'
	fRedLightMaterial=Shader'Luna_Hanger_Tex_HD.new_camera.red_shader'
	fShaftPartClass=Class'B9_AutomationPartShaftCamera'
	fGunPartClass=Class'B9_AutomationPartGunCamera'
	fAlarmList=/* Array type was not detected. */
	ControllerClass=Class'B9_AutomationSecurityCameraController'
	Mesh=SkeletalMesh'B9_Fixtures.camera_base'
	CollisionRadius=15
	CollisionHeight=15
}