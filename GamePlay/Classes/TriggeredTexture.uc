class TriggeredTexture extends Triggers;

// Joe Pearce/Taldren. Fixed to work with ScriptedTexture.uc from Warfare 2110.

var() ScriptedTexture	DestinationTexture;
var() Texture	Textures[10];
var() bool		bTriggerOnceOnly;

var int CurrentTexture;

replication
{
	reliable if( Role==ROLE_Authority )
		CurrentTexture;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	CurrentTexture = 0;

	if( DestinationTexture != None )
		DestinationTexture.Client = Self;
}

simulated event Destroyed()
{
	if( DestinationTexture != None && DestinationTexture.Client == Self)
		DestinationTexture.Client = None;
	
	Super.Destroyed();
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	if( bTriggerOnceOnly && (Textures[CurrentTexture + 1] == None || CurrentTexture == 9) )
		return;

	CurrentTexture++;
	if( Textures[CurrentTexture] == None || CurrentTexture == 10 )
		CurrentTexture = 0;
}

simulated event RenderTexture( ScriptedTexture Tex )
{
	local Color color;
	color.R = 255;
	color.G = 255;
	color.B = 255;
	color.A = 255;
	Tex.DrawTile( 0, 0, Tex.USize, Tex.VSize, 0, 0, Textures[CurrentTexture].USize, Textures[CurrentTexture].VSize, Textures[CurrentTexture], color );
}

defaultproperties
{
	bNoDelete=true
	bAlwaysRelevant=true
	RemoteRole=2
}