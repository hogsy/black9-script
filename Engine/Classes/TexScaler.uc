class TexScaler extends TexModifier
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var float align1;	// Needed for PC & PS2 versions to have the same offset to 'M' in 927 (JP/Taldren)
var float align2;
var float align3;
var Matrix M;
var() float UScale;
var() float VScale;
var() float UOffset;
var() float VOffset;

defaultproperties
{
	UScale=1
	VScale=1
}