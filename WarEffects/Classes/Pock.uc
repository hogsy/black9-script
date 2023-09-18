//=============================================================================
// pock.
//=============================================================================
class Pock extends Scorch;

#exec TEXTURE IMPORT NAME=pock2_t FILE=..\botpack\TEXTURES\DECALS\pock2_t.pcx LODSET=2 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

defaultproperties
{
	ProjTexture=Texture'pock2_t'
	bStatic=false
	DrawScale=0.5
}