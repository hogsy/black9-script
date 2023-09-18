
class ShareSounds extends Actor
	abstract;

#exec Font Import File=..\botpack\Textures\TinyFon2.pcx Name=TinyRedFont

#exec OBJ LOAD FILE=..\botpack\textures\deburst.utx PACKAGE=WarEffects.DBEffect
#exec OBJ LOAD FILE=..\Textures\Belt_fx.utx PACKAGE=WarEffects.Belt_fx
#exec OBJ LOAD FILE=..\botpack\Textures\fireeffect1.utx PACKAGE=WarEffects.Effect1

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Generic\lsplash.WAV" NAME="LSplash" GROUP="Generic"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\pickups\genwep1.WAV" NAME="WeaponPickup" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Generic\land1.WAV" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\GENPICK3.WAV" NAME="GenPickSnd"    GROUP="Pickups"

#exec AUDIO IMPORT FILE="..\botpack\Sounds\eightbal\Eload1.WAV" NAME="Loading" GROUP="EightBall"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\eightbal\Select.WAV" NAME="Selecting" GROUP="EightBall"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\EightBal\Ignite.WAV" NAME="Ignite" GROUP="Eightball"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\EightBal\grenflor.wav" NAME="GrenadeFloor" GROUP="Eightball"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\General\brufly1.WAV" NAME="Brufly1" GROUP="General"

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Gibs\biggib1.WAV" NAME="Gib1" GROUP="Gibs"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Gibs\biggib2.WAV" NAME="Gib4" GROUP="Gibs"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Gibs\biggib3.WAV" NAME="Gib5" GROUP="Gibs"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Gibs\bthump1.WAV" NAME="Thump" GROUP="Gibs"

#exec TEXTURE IMPORT NAME=I_Armor FILE=..\botpack\TEXTURES\HUD\i_armor.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=I_Health FILE=..\botpack\TEXTURES\HUD\i_Health.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=I_ClipAmmo FILE=..\botpack\TEXTURES\HUD\i_clip.PCX GROUP="Icons"

#exec MESH IMPORT MESH=TeleEffect2 ANIVFILE=..\botpack\MODELS\telepo_a.3D DATAFILE=..\botpack\MODELS\telepo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TeleEffect2 X=0 Y=0 Z=-200 YAW=0
#exec MESH SEQUENCE MESH=TeleEffect2 SEQ=All  STARTFRAME=0  NUMFRAMES=30
#exec MESH SEQUENCE MESH=TeleEffect2  SEQ=Burst  STARTFRAME=0  NUMFRAMES=30
#exec MESHMAP SCALE MESHMAP=TeleEffect2 X=0.03 Y=0.03 Z=0.06

#exec AUDIO IMPORT FILE="..\botpack\sounds\pulsegun\dpexplo4.wav" NAME="DispEX1" GROUP="General"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\General\Expl03.wav" NAME="Expl03" GROUP="General"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\General\Expla02.wav" NAME="Expla02" GROUP="General"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\HEALTH2.WAV"  NAME="Health2"     GROUP="Pickups"

#exec AUDIO IMPORT FILE="..\botpack\sounds\flak\expl2.wav" NAME="Explo1" GROUP="General"

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\Scloak1.WAV" NAME="Invisible" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\BOOTSA1.WAV" NAME="BootSnd" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\BOOTJMP.WAV" NAME="BootJmp" GROUP="Pickups"
