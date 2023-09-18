////////////////
//
// B9_AttrCalibration

class B9_AttrCalibration extends B9_Calibration;

enum AttrType
{
	eStrength,
	eAgility,
	eDexterity,
	eConstitution
};

var string fStatStrName;
var string fStatAgiName;
var string fStatDexName;
var string fStatConName;

var int Points;
var AttrType Type;

function SetCalibration(name who, int pts)
{
	PawnName = who;
	Points = pts;
}

function SetType(byte t)
{
	if (t == 0)
		Type = eStrength;
	else if (t == 1)
		Type = eAgility;
	else if (t == 2)
		Type = eDexterity;
	else if (t == 3)
		Type = eConstitution;
}

function Perform(B9_AdvancedPawn Pawn)
{
	// functional part

	if (Type == eStrength)
		B9_PlayerPawn(Pawn).fCharacterBaseStrength += Points;
	else if (Type == eAgility)
		B9_PlayerPawn(Pawn).fCharacterBaseAgility += Points;
	else if (Type == eDexterity)
		B9_PlayerPawn(Pawn).fCharacterBaseDexterity += Points;
	else if (Type == eConstitution)
		B9_PlayerPawn(Pawn).fCharacterBaseConstitution += Points;

	// !!!! visual part
	Log("B9_AttrCalibration::Perform called, points="$string(Points));
}

function Undo(B9_AdvancedPawn Pawn)
{
	// functional part

	if (Type == eStrength)
		B9_PlayerPawn(Pawn).fCharacterBaseStrength -= Points;
	else if (Type == eAgility)
		B9_PlayerPawn(Pawn).fCharacterBaseAgility -= Points;
	else if (Type == eDexterity)
		B9_PlayerPawn(Pawn).fCharacterBaseDexterity -= Points;
	else if (Type == eConstitution)
		B9_PlayerPawn(Pawn).fCharacterBaseConstitution -= Points;

	// debug
	Log("B9_AttrCalibration::Undo called");
}

function string Description(B9_AdvancedPawn Pawn)
{
	local string s;

	if (Type == eStrength)
		s = fStatStrName $ string(Pawn.fCharacterStrength + Points);
	else if (Type == eAgility)
		s = fStatAgiName $ string(Pawn.fCharacterAgility + Points);
	else if (Type == eDexterity)
		s = fStatDexName $ string(Pawn.fCharacterDexterity + Points);
	else if (Type == eConstitution)
		s = fStatConName $ string(Pawn.fCharacterConstitution + Points);

	return s;
}

function bool IsSameKind(B9_Calibration match)
{
	local B9_AttrCalibration cal;

	cal = B9_AttrCalibration(match);
	return (cal != None && cal.Type == Type);
}

defaultproperties
{
	fStatStrName="Increase Strength to "
	fStatAgiName="Increase Agility to "
	fStatDexName="Increase Dexterity to "
	fStatConName="Increase Constitution to "
}