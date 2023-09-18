/////////////////////////////////////////////////////////////
// B9_MissionKitKiosk
//

class B9_MissionKitKiosk extends B9_BuyPhysicalKiosk;

var B9_Intermission.MissionKit kit;
var int TotalPrice;
var int TotalPoints;
var bool InsufficientStrength;
var int NumSkills;

var localized string fStrKitCost;
var localized string fStrKitLowStrength;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");
}

function string ServerTriggerTagName(name TriggerTag)
{
	return "" $ TriggerTag $ "Trigger";
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
	}
}

function SetGenericString(int id, String s)
{
	local class<Inventory> InvClass;
	local int i, j;

	for (i=0;i<Listener.Intermission.MissionKits.Length;i++)
	{
		if (Listener.Intermission.MissionKits[i].Tag == s)
		{
			kit = Listener.Intermission.MissionKits[i];
			fStrCategoryName = kit.KitName;
			NumSkills = CountSkills(RootController.Pawn.Inventory);
			StockItems(kit.Contents);

			for (j=0;j<Stock.Length;j++)
			{
				InvClass = class<Inventory>(DynamicLoadObject(Stock[j].InventoryName, class'Class'));
				if (ClassIsChildOf(InvClass, class'B9_Skill'))
					TotalPoints += Stock[j].Price;
				else
					TotalPrice += Stock[j].Price;
				if (Stock[j].RequiredStrength > B9_PlayerPawn(RootController.Pawn).fCharacterStrength)
					InsufficientStrength = true;
			}

			break;
		}
	}
}

function int CountSkills(Inventory Inv)
{
	local int n;

	while (Inv != None)
	{
		if (B9_Skill(Inv) != None) n++;
		Inv = Inv.Inventory;
	}

	return n;
}

function bool CheckPawnInventory(class TheClass, out B9_HoloItem item, bool noWeapons)
{
	if (ClassIsChildOf(TheClass, class'B9_Skill'))
	{
		// Does player already have this mod?
		item.RealItem = RootController.Pawn.FindInventoryType( TheClass );
		if (item.RealItem != None)
		{
			item.Bought = true;
			item.Price = 1; // for now
		}
		else
		{
			item.Price = NumSkills++;
			if (item.Price < 5) item.Price = 5;
		}
		return false;
	}

	return Super.CheckPawnInventory(TheClass, item, noWeapons);
}

function string GetLeftSummary(B9_HoloItem item)
{
	if (InsufficientStrength)
		return fStrKitLowStrength;
	return fStrKitCost;
}

function string GetRightSummary(B9_HoloItem item)
{
	if (InsufficientStrength)
		return "";
	return "$" $ TotalPrice $ "/" $ TotalPoints $ "P";
}

function AddSkill(B9_PlayerPawn Pawn, B9_HoloItem Item)
{
	Pawn.HQAddSkill(Item.InventoryName);
}

function ModifySkill(B9_PlayerPawn Pawn, B9_HoloItem Item)
{
	Pawn.HQModifySkill(Item.InventoryName, Item.Price);
}

function Purchase()
{
	local B9_PlayerPawn pp;
	local class<Inventory> InvClass;
	local string InvName;
	local int i;

	pp = B9_PlayerPawn(RootController.Pawn);
	for (i=0;i<Stock.Length;i++)
	{
		InvName = Stock[i].InventoryName;
		InvClass = class<Inventory>(DynamicLoadObject(InvName, class'Class'));
		if (ClassIsChildOf(InvClass, class'B9_Skill'))
		{
			if (Stock[i].RealItem != None)
			{
				ModifySkill(pp, Stock[i]);
			}
			else
			{
				AddSkill(pp, Stock[i]);
			}
		}
		else
		{
			pp.HQBuyItem(InvName, Stock[i].Price, PickupDropTagName);
		}
	}

	MenuExit();
}

defaultproperties
{
	fStrKitCost="Kit Cost:"
	fStrKitLowStrength="Insufficient STR to buy"
	PickupDropTagName=MissionKitDropLocation
	fConvertToAmmo=false
}