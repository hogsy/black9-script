// B9_TossedCan

class B9_TossedCan extends Weapon;

// Toss this weapon out
function DropFrom(vector StartLocation)
{
	local Pickup P;
	local Pawn I;
	local rotator rot;
	local float magnitude;

	// change velocity vector
	magnitude = VSize(Velocity);
	rot = rotator(Velocity);
	rot.Pitch = 4000 + 4000 * Frand();
	Velocity = vector(Normalize(rot)) * magnitude;

//	Super.DropFrom(StartLocation);

	I = Instigator; 
	if ( Instigator != None )
	{
		DetachFromPawn(Instigator);	
		Instigator.DeleteInventory(self);
	}	
	SetDefaultDisplayProperties();
	Inventory = None;
	Instigator = None;
	StopAnimating();
	GotoState('');

	P = spawn(PickupClass,,,StartLocation);
	if ( P == None )
	{
		destroy();
		return;
	}
	P.Instigator = I;
	P.InitDroppedPickupFor(self);
	P.Velocity = Velocity;
	Velocity = vect(0,0,0);
}

defaultproperties
{
	bMeleeWeapon=true
	PickupClass=Class'B9_TossedCan_Pickup'
	AttachmentClass=Class'B9_TossedCan_Attachment'
	Icon=Texture'SwarmGunIcon'
	ItemName="Heavy Can"
	Mesh=SkeletalMesh'B9AmbientCreatures_models.ScrubberBot'
	DrawScale=0.25
}