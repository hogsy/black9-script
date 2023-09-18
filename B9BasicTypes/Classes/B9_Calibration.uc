////////////////
//
// B9_Calibration

class B9_Calibration extends Object;

var B9_Calibration Calibration;
var name PawnName;
var bool Permanent;

function B9_Calibration Next()
{
	return Calibration;
}

// must be overridden by subclass
function Perform(B9_AdvancedPawn Pawn);
function Undo(B9_AdvancedPawn Pawn);
function string Description(B9_AdvancedPawn Pawn);
function bool IsSameKind(B9_Calibration match);
