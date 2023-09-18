class TexEnvMap extends TexModifier
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() enum ETexEnvMapType
{
	EM_WorldSpace,
	EM_CameraSpace,
} EnvMapType;

defaultproperties
{
	EnvMapType=1
	TexCoordCount=1
}