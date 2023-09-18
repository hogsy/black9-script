class BloodBurst extends Emitter;

#exec TEXTURE IMPORT NAME=BD3 FILE=..\botpack\MODELS\bd3.pcx GROUP=Blood MASKED=1
#exec TEXTURE IMPORT NAME=BD4 FILE=..\botpack\MODELS\bd4.pcx GROUP=Blood MASKED=1
#exec TEXTURE IMPORT NAME=BD6 FILE=..\botpack\MODELS\bd6.pcx GROUP=Blood MASKED=1
#exec TEXTURE IMPORT NAME=BD9 FILE=..\botpack\MODELS\bd9.pcx GROUP=Blood MASKED=1
#exec TEXTURE IMPORT NAME=BD10 FILE=..\botpack\MODELS\bd10.pcx GROUP=Blood MASKED=1

defaultproperties
{
	bNoDelete=false
	Texture=Texture'Blood.BD3'
}