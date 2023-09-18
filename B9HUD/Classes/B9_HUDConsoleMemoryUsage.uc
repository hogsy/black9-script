//=============================================================================
// B9_HUDConsoleMemoryUsage
//
// 
//
// 
//=============================================================================

class B9_HUDConsoleMemoryUsage extends Actor
//	noexport
	native;

#exec OBJ LOAD FILE=..\textures\Black9_Interface.utx PACKAGE=Black9_Interface

var private texture fMainTexture;
var public bool fVisible;

const kMemoryPanelSizeU = 512;
const kMemoryPanelSizeV = 256;

var font fFont;


struct ConsoleMemoryUsage
{
	var float Animations;	// memory usage for animations
	var float SkeletalMesh;	// memory usage for skeletal meshes only
	var float Sounds;		// memory usage for sounds
	var float StaticMeshes;	// memory usage for static meshes
	var	float StaticMeshesNotCached; // memory usage for static meshes not cached
	var float Textures;		// memory usage for textures
	var	float TexturesNotCached; // memory usage for textures not cached
	var float Objects;		// memory usage for all objects
	var	float ObjectsLessAbove;		// memory usage for all objects minus above
	var float Engine;		// memory usage for Unreal Engine
	var float Total;		// memory usage for the game
	var	float TotalContent;	// memory usage for the game content
	var float SystemMemory;	// Total memory
	var bool  Valid;		// Valid for XBOX and PS2 not PC
};

var native ConsoleMemoryUsage fMemory;

var float fStatsTime;
var bool fGotStats;

native(2300) final function GetMemoryUsage();

function Tick( float deltaTime )
{
	if ( !fVisible )
	{
		return;
	}
	if ( !fGotStats || Level.TimeSeconds - fStatsTime > 5 )
	{
		GetMemoryUsage();
		fStatsTime = Level.TimeSeconds;
		fGotStats = true;
	}
}

function DrawMeter( Canvas canvas, int x, int y, float percent )
{
	Canvas.SetPos( x + 2, y + 2 );
	if ( percent > 0.66 )
	{
		Canvas.SetDrawColor( 255, 55, 55 );
	}
	else if ( percent > 0.33 )
	{
		Canvas.SetDrawColor( 255, 255, 128 );
	}
	else 
	{	
		Canvas.SetDrawColor( 0, 181, 0 );
	}

	Canvas.Style = ERenderStyle.STY_Normal;
//	Canvas.DrawBox( canvas, 248 * percent, 14 );
	canvas.DrawRect( Texture'engine.WhiteSquareTexture', 248 * percent, 15 );
}

function DrawMeter2( Canvas canvas, int x, int y, float percent1, float percent2 )
{
	if (percent2 > 0)
	{
		Canvas.SetPos( x + 2, y + 2 );
		if ( percent1 > 0.66 )
		{
			Canvas.SetDrawColor( 255/2, 55/2, 55/2 );
		}
		else if ( percent1 > 0.33 )
		{
			Canvas.SetDrawColor( 255/2, 255/2, 128/2 );
		}
		else 
		{	
			Canvas.SetDrawColor( 0, 181/2, 0 );
		}

		Canvas.Style = ERenderStyle.STY_Normal;
	//	Canvas.DrawBox( canvas, 248 * percent, 14 );
		canvas.DrawRect( Texture'engine.WhiteSquareTexture', 248 * percent2, 15 );
	}
	if (percent1 - percent2 > 0)
	{
		Canvas.SetPos( x + 2 + 248 * percent2, y + 2 );
		if ( percent1 > 0.66 )
		{
			Canvas.SetDrawColor( 255, 55, 55 );
		}
		else if ( percent1 > 0.33 )
		{
			Canvas.SetDrawColor( 255, 255, 128 );
		}
		else 
		{	
			Canvas.SetDrawColor( 0, 181, 0 );
		}

		Canvas.Style = ERenderStyle.STY_Normal;
	//	Canvas.DrawBox( canvas, 248 * percent, 14 );
		canvas.DrawRect( Texture'engine.WhiteSquareTexture', 248 * (percent1 - percent2), 15 );
	}
}

function Draw( Canvas canvas )
{
	local int x, y;
	local font OldFont;

	if ( fVisible && fGotStats && fMemory.Valid )
	{
		OldFont = Canvas.font;
		Canvas.Font = fFont;

		x = ( canvas.SizeX - kMemoryPanelSizeU ) / 2;
		y = ( canvas.SizeY - kMemoryPanelSizeV ) / 2;
		Canvas.SetPos( x, y );
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawTile( fMainTexture, kMemoryPanelSizeU, kMemoryPanelSizeV, 0, 0, fMainTexture.USize, fMainTexture.VSize );

		Canvas.Style = ERenderStyle.STY_Normal;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.SetPos( x + 435, y + 58 );
		Canvas.DrawText( fMemory.Animations * 1024 );
		Canvas.SetPos( x + 435, y + 72 );
		Canvas.DrawText( fMemory.SkeletalMesh * 1024 );
		DrawMeter2( canvas, x + 170, y + 58, fMemory.Animations / fMemory.SystemMemory, fMemory.SkeletalMesh / fMemory.SystemMemory );

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.SetPos( x + 435, y + 86 );
		Canvas.DrawText( fMemory.Sounds * 1024  );
		DrawMeter( canvas, x + 170, y + 86, fMemory.Sounds / fMemory.SystemMemory );

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.SetPos( x + 435, y + 113 );
		Canvas.DrawText( fMemory.StaticMeshes * 1024  );
		Canvas.SetPos( x + 435, y + 127 );
		Canvas.DrawText( fMemory.StaticMeshesNotCached * 1024  );
		DrawMeter2( canvas, x + 170, y + 113, fMemory.StaticMeshes / fMemory.SystemMemory, fMemory.StaticMeshesNotCached / fMemory.SystemMemory );

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.SetPos( x + 435, y + 142 );
		Canvas.DrawText( fMemory.Textures * 1024  );
		Canvas.SetPos( x + 435, y + 156 );
		Canvas.DrawText( fMemory.TexturesNotCached * 1024  );
		DrawMeter2( canvas, x + 170, y + 142, fMemory.Textures / fMemory.SystemMemory, fMemory.TexturesNotCached / fMemory.SystemMemory );

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.SetPos( x + 435, y + 170 );
		Canvas.DrawText( fMemory.Objects * 1024  );
		Canvas.SetPos( x + 435, y + 184 );
		Canvas.DrawText( fMemory.ObjectsLessAbove * 1024  );
		DrawMeter2( canvas, x + 170, y + 170, fMemory.Objects / fMemory.SystemMemory, fMemory.ObjectsLessAbove / fMemory.SystemMemory );

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.SetPos( x + 435, y + 198 );
		Canvas.DrawText( fMemory.Engine * 1024  );
		DrawMeter( canvas, x + 170, y + 198, fMemory.Engine / fMemory.SystemMemory );

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.SetPos( x + 435, y + 225 );
		Canvas.DrawText( fMemory.Total * 1024  );
		Canvas.SetPos( x + 435, y + 239 );
		Canvas.DrawText( fMemory.TotalContent * 1024  );
		DrawMeter2( canvas, x + 170, y + 225, fMemory.Total / fMemory.SystemMemory, fMemory.TotalContent / fMemory.SystemMemory );

		Canvas.Font = OldFont;
	}
}

defaultproperties
{
	fMainTexture=Texture'Black9_Interface.HUD.MemoryStatus'
	fFont=Font'B9_Fonts.MicroscanA12'
	bHidden=true
}