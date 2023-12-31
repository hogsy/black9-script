//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Sequence / Mesh editor object to expose/shuttle only selected editable 
//  

class SequEditProps extends Object
	hidecategories(Object)
	native;	

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const int WBrowserAnimationPtr;

var(SequenceProperties) float	Rate;
var(SequenceProperties) float	Compression;
var(SequenceProperties) name	SequenceName;
var(Groups) array<name>			Groups;

defaultproperties
{
	Compression=1
}