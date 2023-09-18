// B9_Intermission

class B9_Intermission extends Actor
	placeable;

struct MissionKit
{
	var() string KitName;		// Short name
	var() string Tag;			// Has to match Trigger's Tag
	var() string Description;	// Long description
	var() export editinline array<string> Contents; // "<class>,<price>", all prices are totalled for final price
};

var(Intermission) int ConcludedMission;		// last concluded mission or -1(?) for multi-player character

var(Intermission) localized export editinline array<string> MediaCenterPages;

var(Intermission) export editinline array<string> FirearmsKioskStock;
var(Intermission) export editinline array<string> HeavyWeaponsKioskStock;
var(Intermission) export editinline array<string> ExplosivesKioskStock;
var(Intermission) export editinline array<string> MeleeWeaponsKioskStock;
var(Intermission) export editinline array<string> SpecialWeaponsKioskStock;

var(Intermission) export editinline array<string> ArmorKioskStock;

var(Intermission) export editinline array<string> AmmoPrices;	// ammo of items in kiosks
var(Intermission) export editinline array<string> OtherPrices;	// items you can sell, but not buy
var(Intermission) float SellToPurchasePriceRatio;				// e.g., 0.50 if selling price is half purchase prce

var(Intermission) export editinline array<string> ReconGearKioskStock;
var(Intermission) export editinline array<string> BiomedGearKioskStock;
var(Intermission) export editinline array<string> AddonGearKioskStock;
var(Intermission) export editinline array<string> EnvironmentGearKioskStock;
var(Intermission) export editinline array<string> MiscGearKioskStock;

var(Intermission) export editinline array<string> EnvironmentModKioskStock;
var(Intermission) export editinline array<string> ReconModKioskStock;
var(Intermission) export editinline array<string> OffensiveModKioskStock;
var(Intermission) export editinline array<string> DefensiveModKioskStock;
var(Intermission) export editinline array<string> BiomedModKioskStock;
var(Intermission) export editinline array<string> MiscModKioskStock;

// new kiosks
var(Intermission) export editinline array<string> SkillJumpingKioskStock;
var(Intermission) export editinline array<string> SkillMeleeKioskStock;
var(Intermission) export editinline array<string> SkillHeavyWeaponKioskStock;
var(Intermission) export editinline array<string> SkillLightWeaponKioskStock;
var(Intermission) export editinline array<string> SkillUrbanTrackingKioskStock;
var(Intermission) export editinline array<string> SkillThievesToolkitKioskStock;
var(Intermission) export editinline array<string> SkillMindOverBodyKioskStock;
var(Intermission) export editinline array<string> SkillDrainTechKioskStock;
var(Intermission) export editinline array<string> SkillFireTechKioskStock;
var(Intermission) export editinline array<string> SkillWaterTechKioskStock;
var(Intermission) export editinline array<string> SkillRockTechKioskStock;
var(Intermission) export editinline array<string> SkillWindTechKioskStock;
var(Intermission) export editinline array<string> SkillDefenseTechKioskStock;

var(Intermission) array<MissionKit> MissionKits;

var(Intermission) name BriefingName;	// name of matinee to run to start briefing

var(Intermission) int HealingPrice;		// cost to heal one point of damage above 25% of full health

var(Intermission) Shader MissionMapSlideshow;			// Shader sequence to display on the Mission Map Display
var(Intermission) float	 MissionMapSlideshowFrameTime;	// Seconds each frame of the slideshow will display

var name ServerName; // needed for multi-player

event PostBeginPlay()
{
	ServerName=Name;
}

function bool ValidBuy(array<string> Stock, string Match)
{
	local int i;

	for (i=0;i<Stock.Length;i++)
	{
		Log(Stock[i]);
		if (InStr(Stock[i],Match) != -1)
			return true;
	}
	return false;
}

function bool ConfirmBuyItem(string InvName, int Price, optional bool checkOther)
{
	local string match;

	match = InvName $ "," $ string(Price);

	if (ValidBuy(FirearmsKioskStock, match))
		return true;
	if (ValidBuy(HeavyWeaponsKioskStock, match))
		return true;
	if (ValidBuy(ExplosivesKioskStock, match))
		return true;
	if (ValidBuy(MeleeWeaponsKioskStock, match))
		return true;
	if (ValidBuy(SpecialWeaponsKioskStock, match))
		return true;
	if (ValidBuy(ArmorKioskStock, match))
		return true;
	if (ValidBuy(ReconGearKioskStock, match))
		return true;
	if (ValidBuy(BiomedGearKioskStock, match))
		return true;
	if (ValidBuy(AddonGearKioskStock, match))
		return true;
	if (ValidBuy(EnvironmentGearKioskStock, match))
		return true;
	if (ValidBuy(MiscGearKioskStock, match))
		return true;
	if (ValidBuy(AmmoPrices, match))
		return true;
	if (checkOther && ValidBuy(OtherPrices, match))
		return true;
	return false;
}

function bool ConfirmSellItem(string InvName, out int Price)
{
	if (ConfirmBuyItem(InvName, Price, true))
	{
		Price = float(Price) * SellToPurchasePriceRatio;
		if (Price == 0)
			Price = 1;
		return true;
	}

	return false;
}

function bool ConfirmBuyMod(string InvName, int Price)
{
	local string match;

	match = InvName $ "," $ string(Price);
	Log(match);

	if (ValidBuy(EnvironmentModKioskStock, match))
		return true;
	if (ValidBuy(ReconModKioskStock, match))
		return true;
	if (ValidBuy(OffensiveModKioskStock, match))
		return true;
	if (ValidBuy(DefensiveModKioskStock, match))
		return true;
	if (ValidBuy(BiomedModKioskStock, match))
		return true;
	if (ValidBuy(MiscModKioskStock, match))
		return true;
	return false;
}

defaultproperties
{
	SellToPurchasePriceRatio=0.6
	HealingPrice=1
	bHidden=true
	bAlwaysRelevant=true
}