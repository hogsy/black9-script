class ClientScriptedTexture extends Info;

// Joe Pearce/Taldren. Fixed to work with ScriptedTexture.uc from Warfare 2110.

var() ScriptedTexture ScriptedTexture;

simulated function BeginPlay()
{
	if(ScriptedTexture != None)
		ScriptedTexture.Client = Self;
}

simulated function Destroyed()
{
	if(ScriptedTexture != None)
		ScriptedTexture.Client = None;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
}

defaultproperties
{
	bNoDelete=true
	bAlwaysRelevant=true
	RemoteRole=2
}