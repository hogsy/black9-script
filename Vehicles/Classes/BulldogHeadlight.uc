#exec OBJ LOAD FILE=..\Textures\BulldogSkin.utx

class BulldogHeadlight extends DynamicProjector;

// Empty tick here - do detach/attach in Bulldog tick
function Tick(float Delta)
{

}

defaultproperties
{
	FrameBufferBlendingOp=3
	ProjTexture=Texture'BulldogSkin.Lights.BullHeadlights'
	FOV=30
	MaxTraceDistance=2048
	bClipBSP=true
	bProjectOnUnlit=true
	bGradient=true
	bProjectOnAlpha=true
	bProjectOnParallelBSP=true
	bLightChanged=true
	bHardAttach=true
	DrawScale=0.65
}