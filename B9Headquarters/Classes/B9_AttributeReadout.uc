// B9_AttributeReadout.uc

class B9_AttributeReadout extends Actor
	placeable;

//#exec OBJ LOAD FILE=..\textures\B9_Fonts.utx PACKAGE=B9_Fonts
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures

var font myFont;
var texture fStrIcon;
var texture fAglIcon;
var texture fDexIcon;
var texture fConIcon;

var B9_PlayerPawn Subject;
var int ScrollY;
var int ScrollDelta;
var int PageHeight;
var float TimeInterval;

var() ScriptedTexture	DestTexture;

var() localized string MSA16Font;

simulated function PostBeginPlay()
{
	if(DestTexture != None)
		DestTexture.Client = Self;

	//myFont = font'B9_Fonts.MicroscanA16';
	myFont = Font( DynamicLoadObject( MSA16Font, class'Font' ) );
	//if ( myFont == None )
	//{
	//	Log( "SCDTemp/B9_AttributeReadout::PostBeginPlay():No myFont" );
	//}
	//else
	//{
	//	Log( "SCDTemp/B9_AttributeReadout::PostBeginPlay(): myFont is"$myFont.Name );
	//}
}

function SetSubject(B9_PlayerPawn pp)
{
	Subject = pp;
	SetTimer(TimeInterval, true);
	ScrollY = 0;
}

function UnsetSubject(B9_PlayerPawn pp)
{
	if (Subject == pp)
	{
		Subject = None;
		SetTimer(TimeInterval, false);
	}
}

event Trigger( Actor Other, Pawn Instigator )
{
	local B9_PlayerPawn PP;

	PP = B9_PlayerPawn(Instigator);
	if (PP != None)
		SetSubject(PP);
}

event Untrigger( Actor Other, Pawn Instigator )
{
	local B9_PlayerPawn PP;

	PP = B9_PlayerPawn(Instigator);
	if (PP != None)
		UnsetSubject(PP);
}

function Timer()
{
	ScrollY = (ScrollY + ScrollDelta) % PageHeight;
	DestTexture.Revision++;
}

function bool CalcY(out int y, int h)
{
	y -= ScrollY;
	if (y + h >= 0 && y < DestTexture.VSize)
		return true;
	y = (y + PageHeight) % PageHeight;
	return (y + h >= 0 && y < DestTexture.VSize);
}

event RenderTexture(ScriptedTexture st)
{
	local Color color;
	local int sx, sy;
	local int y;

	if (Subject == None)
		return;

	color.R = 255;
	color.G = 255;
	color.B = 255;
	color.A = 255;

	y = 0;
	if (CalcY(y, 24))
	{
		st.TextSize(subject.fCharacterName, myFont, sx, sy);
		st.DrawText(64 - sx / 2, y, subject.fCharacterName, myFont, color);
	}

	y = 24;
	if (CalcY(y, 24))
	{
		st.DrawTile(2, y, 32, 16, 0, 0, 32, 16, fStrIcon, color);
		st.DrawText(40, y, string(subject.fCharacterStrength), myFont, color);
		st.DrawTile(64, y, 32, 16, 0, 0, 32, 16, fAglIcon, color);
		st.DrawText(102, y, string(subject.fCharacterAgility), myFont, color);
	}

	y = 48;
	if (CalcY(y, 24))
	{
		st.DrawTile(2, y, 32, 16, 0, 0, 32, 16, fDexIcon, color);
		st.DrawText(40, y, string(subject.fCharacterDexterity), myFont, color);
		st.DrawTile(64, y, 32, 16, 0, 0, 32, 16, fConIcon, color);
		st.DrawText(102, y, string(subject.fCharacterConstitution), myFont, color);
	}
}

defaultproperties
{
	fStrIcon=Texture'B9Menu_textures.Icons.str_icon'
	fAglIcon=Texture'B9Menu_textures.Icons.agl_icon'
	fDexIcon=Texture'B9Menu_textures.Icons.dex_icon'
	fConIcon=Texture'B9Menu_textures.Icons.con_icon'
	ScrollDelta=2
	PageHeight=152
	TimeInterval=0.05
	MSA16Font="B9_Fonts.MicroscanA16"
	bHidden=true
	bNoDelete=true
	bAlwaysRelevant=true
}