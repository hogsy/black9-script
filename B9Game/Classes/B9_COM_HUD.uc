class B9_COM_HUD extends B9_HUD;


var public B9_CommandHUD  fCommandHUD;


function PreBeginPlay()
{
	Super.PreBeginPlay();
	fCommandHUD = Spawn( class 'B9_CommandHUD', self );
}

exec function ToggleHUD()
{
	Super.ToggleHUD();
	fCommandHUD.ToggleInView();
}

function DrawHUD(canvas Canvas)
{
	Super.DrawHUD( Canvas );
	if ( !fHideHUD )
		fCommandHUD.Draw(Canvas);
}
