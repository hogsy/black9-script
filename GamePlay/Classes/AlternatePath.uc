//=============================================================================
// AlternatePath.
//=============================================================================
class AlternatePath extends NavigationPoint
	notplaceable;

var() byte Team;
var() float SelectionWeight;
var() bool bReturnOnly;

defaultproperties
{
	SelectionWeight=1
	bObsolete=true
}