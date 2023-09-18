class B9_MPHQ_HUD extends B9_HUD;


var public B9_MPHQ_HUD_Panel  fHQHUD;


replication
{
	reliable if ( ( Role == ROLE_Authority ) && bNetOwner )
		fHQHUD;
}


function PreBeginPlay()
{
	Super.PreBeginPlay();
	fHQHUD = Spawn( class 'B9_MPHQ_HUD_Panel', self );
}

exec function ToggleHUD()
{
	Super.ToggleHUD();
	fHQHUD.ToggleInView();
}

function DrawHUD(canvas Canvas)
{
	Super.DrawHUD( Canvas );
	if ( !fHideHUD )
		fHQHUD.Draw(Canvas);
}
