////////////////
//
// B9_BodyModCalibration

class B9_BodyModCalibration extends B9_Calibration;

var B9_HoloItem HoloMod;
var bool bIsAdded;

function SetCalibration(name who, B9_HoloItem item)
{
	PawnName = who;
	HoloMod = item;
}

function Perform(B9_AdvancedPawn Pawn)
{
	local B9_CharMod mod;

	// functional part
	if (!bIsAdded)
	{
		mod = Pawn.Spawn( class<B9_CharMod>(Pawn.DynamicLoadObject(HoloMod.InventoryName, class'Class')) );
		Pawn.AddInventory(mod);
		bIsAdded = !Permanent;
	}

	// !!!! visual part
	Log("B9_BodyModCalibration::Perform called");
}

function Undo(B9_AdvancedPawn Pawn)
{
	local Inventory mod;

	// functional part
	if (bIsAdded)
	{
		mod = Pawn.FindInventoryType( class<B9_CharMod>(Pawn.DynamicLoadObject(HoloMod.InventoryName, class'Class')) );
		if (mod != None)
		{
			Pawn.DeleteInventory(mod);
			mod.Destroy();
		}
		bIsAdded = false;
	}

	// debug
	Log("B9_BodyModCalibration::Undo called");
}

function string Description(B9_AdvancedPawn Pawn)
{
	return HoloMod.LongDisplayName;
}

