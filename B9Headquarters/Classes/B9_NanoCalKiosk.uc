/////////////////////////////////////////////////////////////
// B9_NanoCalKiosk
//

class B9_NanoCalKiosk extends B9_AttrModKiosk;

var B9_Skill Skill;

function string ServerTriggerTagName(name TriggerTag)
{
	return "" $ TriggerTag $ "Trigger";
}

function bool FindFullClassName(array<string> stock, out string fullname)
{
	local string s;
	local int i;
	local int n;

	for (i=0;i<stock.Length;i++)
	{
		s = stock[i];
		n = InStr(s, fullname);
		if (n > 0 && Mid(s, n - 1, 1) == "." && Mid(s, n + Len(fullname), 1) == ",")
		{
			fullname = Left(s, n + Len(fullname));
			return true;
		}
	}

	return false;
}

function SetGenericObject(int id, object o)
{
	SetSkill(B9_Skill(o));
}

function SetSkill(B9_Skill sk)
{
	local B9_HoloItem item;
	local class<B9_HoloItem> itemClass;
	local B9_Intermission intermission;
	local B9_NanoCalibration cal;
	local string fullName;
	local bool found;

	Skill = sk;

	fStatName = Skill.fSkillName;

	intermission = Listener.Intermission;
	fullName = "" $ Skill.Class.Name;

	found = FindFullClassName(intermission.EnvironmentModKioskStock, fullName);
	if (!found)
		found = FindFullClassName(intermission.ReconModKioskStock, fullName);
	if (!found)
		found = FindFullClassName(intermission.OffensiveModKioskStock, fullName);
	if (!found)
		found = FindFullClassName(intermission.DefensiveModKioskStock, fullName);
	if (!found)
		found = FindFullClassName(intermission.BiomedModKioskStock, fullName);
	if (!found)
		found = FindFullClassName(intermission.MiscModKioskStock, fullName);
	
	Log("SetSkill: fullName=" $ fullName);

	ItemClass = class<B9_HoloItem>(DynamicLoadObject(fullName $ "_Holo", class'Class'));
	if (ItemClass != None)
	{
		item = RootController.spawn(ItemClass);
		if (item != None)
		{
			SetDescription(item.Description);
			item.Destroy();
		}
	}

	cal = new(None) class'B9_NanoCalibration';
	cal.RealSkill = Skill;
	SetStatInfo( Skill.fStrength, B9_PlayerPawn(RootController.Pawn).fCharacterSkillPoints, cal );
}

function AddNanoCalibration(B9_NanoCalibration cal, int adjustment)
{
	local B9_PlayerPawn Pawn;
	
	Pawn = B9_PlayerPawn(RootController.Pawn);

	// add or remove locally
	if (cal.points != 0) Listener.AddCalibration(cal);
	else Listener.RemoveCalibration(cal);

	if (Pawn.Role < ROLE_Authority)
		Pawn.HQAddNanoCalibration(cal.RealSkill, cal.Points, adjustment);
	else
		Pawn.fCharacterSkillPoints -= adjustment;
}

function CompleteTransaction()
{
	local int points, adjustment;
	local B9_NanoCalibration cal;

	cal = B9_NanoCalibration(GetPointsUsed(points, adjustment));
	if (cal != None)
	{
		cal.SetCalibration(RootController.Pawn.Name, points);

		AddNanoCalibration(cal, adjustment);
	}

	MenuExit();
}

defaultproperties
{
	fStrCurrent="Current Skill: "
	fStrModified="New Skill: "
}