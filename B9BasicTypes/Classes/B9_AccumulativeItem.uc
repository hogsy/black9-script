//=============================================================================
// B9_AccumulativeItem
//
// 
//	A B9_Powerup which behaves similarly to Ammunition
// 
//=============================================================================

class B9_AccumulativeItem extends B9_Powerups
	abstract;

var travel int MaxAmount;					// Max amount of items
var travel int Amount;						// Amount of items current available
var travel int PickupAmount;				// Amount of items to give when this is picked up for the first time	

// Damage and Projectile information

var class<Projectile> ProjectileClass;
var class<DamageType> MyDamageType;
var float WarnTargetPct;
var float RefireRate;

var Sound FireSound;

// Network replication
//

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		Amount;
}


simulated function bool HasItems()
{
	return ( Amount > 0 );
}

function WarnTarget(Actor Target,Pawn P ,vector FireDir)
{
	if ( (FRand() < WarnTargetPct) && (Pawn(Target) != None) && (Pawn(Target).Controller != None) ) 
		Pawn(Target).Controller.ReceiveWarning(P, ProjectileClass.Default.Speed, FireDir); 
}

function SpawnProjectile(vector Start, rotator Dir)
{
	Amount -= 1;
	Spawn(ProjectileClass,,, Start,Dir);	
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.DrawText("B9_AccumulativeItem "$GetItemName(string(self))$" amount "$Amount$" Max "$MaxAmount);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}
	
function bool HandlePickupQuery( pickup Item )
{
	if ( class == item.InventoryType ) 
	{
		if (Amount==MaxAmount) 
			return true;
		item.AnnouncePickup(Pawn(Owner));
		AddItem(B9_AccumulativeItemPickup(item).Amount);
		return true;				
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

// If we can, add item and return true.  
// If we are at max item, return false
//
function bool AddItem(int AmountToAdd)
{
	Amount = Min(MaxAmount, Amount+AmountToAdd);
	return true;
}

function Use( float value )
{
	Amount -= 1;
	if (Amount <= 0)
	{
		Pawn(Owner).DeleteInventory(self);
		Destroy();
	}
}

function float GetDamageRadius()
{
	if ( ProjectileClass != None )
		return ProjectileClass.Default.DamageRadius;

	return 0;
}

defaultproperties
{
	MyDamageType=Class'Engine.DamageType'
	RefireRate=0.5
}