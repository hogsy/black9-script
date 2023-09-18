class ACTION_ChangeWeapon extends ScriptedAction;

var(Action) class<Weapon> NewWeapon;

function bool InitActionFor(ScriptedController C)
{
///////////////////////////////////
// AS,Taldren,
// 
//
	// Give weapon to inventory of pawn
	C.Pawn.GiveWeaponByClass( newWeapon );
//
// AS, end changes
//////////////////////

	// Equip weapon
	C.Pawn.PendingWeapon = Weapon(C.Pawn.FindInventoryType(newWeapon));
	C.Pawn.ChangedWeapon();

	return false;	
}
