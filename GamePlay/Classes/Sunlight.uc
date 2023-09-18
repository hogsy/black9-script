//=============================================================================
// Directional sunlight
//=============================================================================
class Sunlight extends Light;

#exec Texture Import File=Textures\SunIcon.pcx  Name=SunIcon Mips=Off MASKED=1

defaultproperties
{
	LightEffect=19
	Texture=Texture'SunIcon'
	bDirectional=true
}