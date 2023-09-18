// ====================================================================
//  Class:  WarClassHeavy.WeapGeistMinigun
//  Parent: WarClassHeavy.WeapCogMinigun
//
//  <Enter a description here>
// ====================================================================

class WeapGeistMinigun extends WeapCogMinigun;

var actor 	AltThirdPersonActor;
var mesh	AltThirdPersonMesh;
var float	AltThirdPersonScale;
var vector AltThirdPersonRelativeLocation;
var rotator AltThirdPersonRelativeRotation;
var class<InventoryAttachment> AltAttachmentClass;

event Destroyed()
{
	if (AltThirdPersonActor != None)
		AltThirdPersonActor.Destroy();
	
	Super.Destroyed();
		
}

simulated function AttachToPawn(Pawn P)
{
	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(ThirdPersonActor).InitFor(self);
	}

	if ( AltThirdPersonActor == None )
	{
		AltThirdPersonActor = Spawn(AltAttachmentClass,Owner);
		InventoryAttachment(AltThirdPersonActor).InitFor(self);
	}
	
	P.AttachToBone(ThirdPersonActor,'l_elbow');

	AttachmentGeistMiniGun(ThirdPersonActor).SetFlashBone('l_elbow',false);
	
	P.AttachToBone(AltThirdPersonActor,'r_elbow');
	AltThirdPersonActor.SetRelativeLocation(AltThirdPersonRelativeLocation);
	AltThirdPersonActor.SetRelativeRotation(AltThirdPersonRelativeRotation);
	AttachmentGeistMiniGun(AltThirdPErsonActor).SetFlashBone('r_elbow',true);

	AttachmentGeistMiniGun(ThirdPersonActor).Next = AttachmentGeistMiniGun(AltThirdPersonActor);

}


defaultproperties
{
	AltThirdPersonRelativeLocation=(X=-3.8,Y=0,Z=0)
	AltThirdPersonRelativeRotation=(Pitch=0,Yaw=16384,Roll=0)
	AltAttachmentClass=Class'AttachmentGeistMinigun'
	AttachmentClass=Class'AttachmentGeistMinigun'
}