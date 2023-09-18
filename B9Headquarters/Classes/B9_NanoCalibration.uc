//
// B9_NanoCalibration

class B9_NanoCalibration extends B9_Calibration;

var B9_Skill RealSkill;
var int Points;

var localized string fStrIncrease;
var localized string fStrTo;

function SetCalibration(name who, int pts)
{
	PawnName = who;
	Points = pts;
}

function SetSkill(B9_Skill skill)
{
	RealSkill = skill;
}

function Perform(B9_AdvancedPawn Pawn)
{
	// functional part
	RealSkill.fStrength += Points;
	if (Permanent)
		RealSkill = None;

	// !!!! visual part
	Log("B9_NanoModCalibration::Perform called");
}

function Undo(B9_AdvancedPawn Pawn)
{
	// functional part
	RealSkill.fStrength -= Points;

	// debug
	Log("B9_NanoModCalibration::Undo called");
}

function string Description(B9_AdvancedPawn Pawn)
{
	local int n;
	
	n = Points + RealSkill.fStrength;

	return fStrIncrease $ RealSkill.fSkillName $ fStrTo $ string(n);
}


function bool IsSameKind(B9_Calibration match)
{
	local B9_NanoCalibration cal;

	cal = B9_NanoCalibration(match);
	return (cal != None && cal.RealSkill.class == RealSkill.class);
}

defaultproperties
{
	fStrIncrease="Increase "
	fStrTo=" to "
}