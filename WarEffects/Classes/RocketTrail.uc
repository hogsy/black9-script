//=============================================================================
// RocketTrail.
//=============================================================================
class RocketTrail extends Emitter;

#exec TEXTURE IMPORT NAME=JRFlare FILE=..\BotPack\MODELS\flare9.PCX

defaultproperties
{
	Physics=10
	bNoDelete=false
	bTrailerSameRotation=true
	Mass=16
}