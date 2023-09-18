//=============================================================================
// ConversationPanel
//
//	Scrolling text area for in-game dialogue
// 
//=============================================================================


class ConversationPanel extends B9_HUDPanel;


/////////////////////////////////////////////
// Variables
//

struct	ConversationLine
{
	var string		fString;
	var int			fPosX, fPosY;
};

var material			fPanelMaterial;
var material			fPanelBacking;

const	kPanelX			= 35;
//const	kPanelY			= 140;
const	kPanelHeight	= 140;
const	kPanelMaterialX	= 128;
const	kPanelMaterialY	= 32;
const	kSpacer			= 3;
const	kTVScreenBuffer = 32;

var	font fMyFont;
var array<ConversationLine>		fLines;

/////////////////////////////////////////////
// Functions
//

function ClearAll()
{
	local int i;

	for( i = 0; i < fLines.Length; i++ )
	{
		fLines.Remove( i, 1 );
	}
}

function AddString( string s )
{
	local float strX, strY;

	fLines.Length = fLines.Length + 1;
	fLines[fLines.Length - 1].fString	= s;
	fLines[fLines.Length - 1].fPosX		= 10;
	fLines[fLines.Length - 1].fPosY		= 0; // Don't bother doing the math yet since we need the Canvas
}

function Draw( Canvas canvas )
{
	local float		oldOrgX, oldOrgY;
	local float		oldClipX, oldClipY;
	local int		kPanelY;

	DrawPanel( canvas );

	kPanelY		= canvas.clipY - 150 - kTVScreenBuffer;

	oldOrgX		= canvas.OrgX;
	oldOrgY		= canvas.OrgY;
	oldClipX	= canvas.ClipX;
	oldClipY	= canvas.ClipY;

	canvas.SetOrigin( kPanelX+5, kPanelY+5 );
	canvas.SetClip( ( canvas.ClipX - ( kPanelX * 2 ) - 5 ), kPanelHeight-5 );

	UpdateStringPositions( canvas );
	DrawStrings( canvas );

	canvas.SetOrigin( oldOrgX, oldOrgY ); 
	canvas.SetClip( oldClipX, oldClipY ); 
}

function UpdateStringPositions( Canvas C )
{
    local int i;
	local float	strX, strY, neededTotalY;
	local B9_HUD	b9HUD;

	C.Font			= fMyFont;
	strX			= 0.0;
	strY			= 0.0;
	neededTotalY	= 0.0;

	// Adjust Y-pos of each string
	// Also keep track of the total Y needed so we can remove strings as necessary
	//
    for( i = 0; i < fLines.Length; i++ )
	{
		C.StrLen( fLines[i].fString, strX, strY );
		neededTotalY += strY;
		
		if( i == 0 )
		{
			fLines[i].fPosY = 0;
		}
		else
		{
			C.StrLen( fLines[i-1].fString, strX, strY );
			fLines[i].fPosY = ( ( fLines[i-1].fPosY + strY ) + kSpacer );
			neededTotalY += kSpacer;
		}
	}

	// If we come up short on text area, pop off the oldest string
	// and recurse until it all fits.
	//
	if( neededTotalY > ( kPanelHeight - 20 ) )
	{
		fLines.Remove( 0, 1 );
		UpdateStringPositions( C );
	}
}

function DrawStrings( Canvas C )
{
	local int		i;
	
//	C.Font	= b9HUD.fSmallFont;
	C.SetDrawColor( 210, 210, 210 );

	for( i = 0; i < fLines.Length; i++ )
	{
		C.SetPos( fLines[i].fPosX, fLines[i].fPosY );
		C.DrawText( fLines[i].fString );
	}	
}

function DrawPanel( Canvas C )
{
	local int kPanelY;

	kPanelY		= C.clipY - 150 - kTVScreenBuffer;

	C.SetPos( kPanelX, kPanelY );
	C.DrawTileClipped( fPanelBacking, ( C.ClipX - ( kPanelX * 2 ) ), kPanelHeight, 10, 10, 20, 20 );

	C.SetPos( kPanelX, kPanelY );
	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor( 255, 255, 255, 128 );

	C.DrawTile( fPanelMaterial,
				( C.ClipX - ( kPanelX * 2 ) ),
				kPanelHeight, 
				0,
				0,
				kPanelMaterialX,
				kPanelMaterialY  );
}



/////////////////////////////////////////////
// Initialization
//






defaultproperties
{
	fPanelMaterial=Texture'B9Menu_textures.GameBrowser.large_cell_hilite'
	fPanelBacking=Texture'B9Menu_textures.GameBrowser.large_cell'
	fMyFont=Font'B9_Fonts.MicroscanA16'
}