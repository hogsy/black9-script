// ====================================================================
//  Class:  WarClassHeavy.AttachmentRocketAmmoSlot
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class AttachmentRocketAmmoSlot extends AmmoAttachment;

var Pawn Target;
var byte Status;

replication
{
	reliable if (ROLE==ROLE_Authority)
		Target, Status;
}

function LockOn(pawn NewTarget)
{
	Status = 1;					// Locked
	Target = NewTarget;
}			

function Clear()
{
	Target = None;
	if (Status==1)
		Status = 0;
}
		
state Reload
{

	function Timer()
	{
	
		local RocketAmmo MyOwner;

		MyOwner = RocketAmmo(Owner);

		// Attempt to reload;

		if (MyOwner.AmmoAmount>0)
		{
			MyOwner.AmmoAmount--;
			Status = 0;				// Ready
		}
		else
			Status = 3;	// Awaiting Ammo
			
		GotoState('');
	}

	function BeginState()
	{
		Status = 2;			// Inactive/Reloading
		SetTimer(5.0,false);
	}

}		
		
		
defaultproperties
{
	RemoteRole=1
}