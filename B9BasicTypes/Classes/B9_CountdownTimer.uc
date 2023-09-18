// B9_CountdownTimer.uc

/*
"Countdown Timer"

placeable
listen to event to begin/end countdown
send event on time expired

display countdown on HUD
flash red for "time almost up"

play sounds for "tick" or "time almost up"

cofigure total time
cofigure "time almost up" (percentage of total?)
cofigure sound for "tick"
cofigure sound for flashing red
configure event for "time almost up"
configure event for "time expired"



OPTIONAL FEATURES
(might be handy for additional gameplay stuff)

reset - back to full time
bonus time - add seconds during countdown
penalty time - lose seconds during countdown
freeze - freeze and resume countdown
*/

class B9_CountdownTimer extends Actor
	placeable;
	
var(CountdownTimer) int fTotalSeconds;	// total countdown time in seconds
var(CountdownTimer) int fAlertSeconds;	// "time almost up" time in seconds
var(CountdownTimer) sound fNormalTickSound;
var(CountdownTimer) sound fAlertTickSound;
var(CountdownTimer) name fAlertEvent;
var(CountdownTimer) name fExpireEvent;

var float fCurrentTicks;
var bool fRunning;
var Pawn fOriginalInstigator;

function ResetCountdown()
{
	fCurrentTicks = fTotalSeconds;
	fOriginalInstigator.Trigger(self, fOriginalInstigator);
}

function AdjustCountdown(int secs)
{
	fCurrentTicks += secs;
	if (fCurrentTicks <= 0.0f)
		fCurrentTicks = 0.1f;
	fOriginalInstigator.Trigger(self, fOriginalInstigator);
}

function RunCountdown(bool run)
{
	fRunning = run;
	if (fRunning)
	{
		if (fCurrentTicks <= 0.0f)
			ResetCountdown();
	}
	fOriginalInstigator.Trigger(self, fOriginalInstigator);
}

event Tick( float DeltaTime )
{
	if (fRunning)
	{
		fCurrentTicks -= DeltaTime;
		if (fCurrentTicks <= 0.0f)
		{
			fCurrentTicks = 0.0f;
			fRunning = false;
			TriggerEvent(fExpireEvent, self, fOriginalInstigator);
			fOriginalInstigator.Trigger(self, fOriginalInstigator);
		}
		else if (fCurrentTicks + DeltaTime > fAlertSeconds && fCurrentTicks <= fAlertSeconds)
		{
			TriggerEvent(fAlertEvent, self, fOriginalInstigator);
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	fOriginalInstigator = EventInstigator.Instigator;
	if (fRunning)
	{
		fRunning = false;
		fCurrentTicks = 0.0f;
	}
	else
	{
		fRunning = true;
		fCurrentTicks = fTotalSeconds;
	}
	fOriginalInstigator.Trigger(self, fOriginalInstigator);
}

defaultproperties
{
	fTotalSeconds=30
	fAlertSeconds=10
	fNormalTickSound=Sound'B9Interface_sounds.menus.menu_beep01'
	fAlertTickSound=Sound'B9Interface_sounds.menus.menu_beep03'
	fAlertEvent=CountdownAlert
	fExpireEvent=CountdownExpire
	bHidden=true
}