class UDebugMapListWindow extends UWindowFramedWindow;


function Created() 
{
	bSizable = True;
	MinWinWidth = 200;
	Super.Created();
}

defaultproperties
{
	ClientClass=Class'UDebugMapListCW'
	WindowTitle="Select a Map..."
}