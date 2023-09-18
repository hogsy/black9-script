class SubActionCameraEffect extends MatSubAction
	native
	noexport
	collapsecategories;

var() editinline CameraEffect	CameraEffect;
var() float						StartAlpha,
								EndAlpha;
var() bool						DisableAfterDuration;

defaultproperties
{
	EndAlpha=1
	Icon=Texture'SubActionFade'
	Desc="Camera effect"
}