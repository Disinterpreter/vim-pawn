" Vim syntax file
" Language:	Pawn
" URL:		https://github.com/mcnelson/vim-pawn
" Forked from https://github.com/withgod/vim-sourcepawn

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" A bunch of useful C keywords
syn keyword	cStatement	goto break return continue assert state sleep exit new
syn keyword	cLabel		case default
syn keyword	cConditional	if else switch
syn keyword	cRepeat		while for do

syn keyword	cTodo		contained TODO FIXME XXX

" It's easy to accidentally add a space after a backslash that was intended
" for line continuation.  Some compilers allow it, which makes it
" unpredicatable and should be avoided.
syn match	cBadContinuation contained "\\\s\+$"

" cCommentGroup allows adding matches for special things in comments
syn cluster	cCommentGroup	contains=cTodo,cBadContinuation

" String and Character constants
" Highlight special characters (those which have a backslash) differently
syn match	cSpecial	display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
if !exists("c_no_utf")
  syn match	cSpecial	display contained "\\\(u\x\{4}\|U\x\{8}\)"
endif
if exists("c_no_cformat")
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,@Spell
  " cCppString: same as cString, but ends at end of line
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,@Spell
else
  if !exists("c_no_c99") " ISO C99
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  else
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlL]\|ll\)\=\([bdiuoxXDOUfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  endif
  syn match	cFormat		display "%%" contained
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell
  " cCppString: same as cString, but ends at end of line
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell
endif

syn match	cCharacter	"L\='[^\\]'"
syn match	cCharacter	"L'[^']*'" contains=cSpecial
if exists("c_gnu")
  syn match	cSpecialError	"L\='\\[^'\"?\\abefnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abefnrtv]'"
else
  syn match	cSpecialError	"L\='\\[^'\"?\\abfnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abfnrtv]'"
endif
syn match	cSpecialCharacter display "L\='\\\o\{1,3}'"
syn match	cSpecialCharacter display "'\\x\x\{1,2}'"
syn match	cSpecialCharacter display "L'\\x\x\+'"

"when wanted, highlight trailing white space
if exists("c_space_errors")
  if !exists("c_no_trail_space_error")
    syn match	cSpaceError	display excludenl "\s\+$"
  endif
  if !exists("c_no_tab_space_error")
    syn match	cSpaceError	display " \+\t"me=e-1
  endif
endif

" This should be before cErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syntax match cCurlyError "}"
  syntax region	cBlock		start="{" end="}" contains=ALLBUT,cCurlyError,@cParenGroup,cErrInParen,cCppParen,cErrInBracket,cCppBracket,cCppString,@Spell fold
else
  syntax region	cBlock		start="{" end="}" transparent fold
endif

"catch errors caused by wrong parenthesis and brackets
" also accept <% for {, %> for }, <: for [ and :> for ] (C99)
" But avoid matching <::.
syn cluster	cParenGroup	contains=cParenError,cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom
if exists("c_no_curly_error")
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
  syn match	cParenError	display ")"
  syn match	cErrInParen	display contained "^[{}]\|^<%\|^%>"
elseif exists("c_no_bracket_error")
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
  syn match	cParenError	display ")"
  syn match	cErrInParen	display contained "[{}]\|<%\|%>"
else
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cErrInBracket,cCppBracket,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cErrInBracket,cParen,cBracket,cString,@Spell
  syn match	cParenError	display "[\])]"
  syn match	cErrInParen	display contained "[\]{}]\|<%\|%>"
  syn region	cBracket	transparent start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,@cParenGroup,cErrInParen,cCppParen,cCppBracket,cCppString,@Spell
  " cCppBracket: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppBracket	transparent start='\[\|<::\@!' skip='\\$' excludenl end=']\|:>' end='$' contained contains=ALLBUT,@cParenGroup,cErrInParen,cParen,cBracket,cString,@Spell
  syn match	cErrInBracket	display contained "[);{}]\|<%\|%>"
endif

"integer number, or floating point number without a dot and with "f".
syn case ignore
syn match	cNumbers	display transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctalError,cOctal
" Same, but without octal error (for comments)
syn match	cNumbersCom	display contained transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctal
syn match	cNumber		display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
"hex number
syn match	cNumber		display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
" Flag the first zero of an octal number as something special
syn match	cOctal		display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=cOctalZero
syn match	cOctalZero	display contained "\<0"
syn match	cFloat		display contained "\d\+f"
"floating point number, with dot, optional exponent
syn match	cFloat		display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
"floating point number, starting with a dot, optional exponent
syn match	cFloat		display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
"floating point number, without dot, with exponent
syn match	cFloat		display contained "\d\+e[-+]\=\d\+[fl]\=\>"
if !exists("c_no_c99")
  "hexadecimal floating point number, optional leading digits, with dot, with exponent
  syn match	cFloat		display contained "0x\x*\.\x\+p[-+]\=\d\+[fl]\=\>"
  "hexadecimal floating point number, with leading digits, optional dot, with exponent
  syn match	cFloat		display contained "0x\x\+\.\=p[-+]\=\d\+[fl]\=\>"
endif

" flag an octal number with wrong digits
syn match	cOctalError	display contained "0\o*[89]\d*"
syn case match

if exists("c_comment_strings")
  " A comment can contain cString, cCharacter and cNumber.
  " But a "*/" inside a cString in a cComment DOES end the comment!  So we
  " need to use a special type of cString: cCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syntax match	cCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syntax region cCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=cSpecial,cCommentSkip
  syntax region cComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=cSpecial
  syntax region  cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syntax region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell extend
  else
    syntax region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell fold extend
  endif
else
  syn region	cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell extend
  else
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syntax match	cCommentError	display "\*/"
syntax match	cCommentStartError display "/\*"me=e-1 contained

syn keyword	cOperator	sizeof tagof state defined char

syn keyword	cTag 		any bool Fixed Float String Function

syn keyword	cStructure	enum
syn keyword	cStorageClass	static const stock native forward public

" Constants
" ======
syn keyword 	cConstant 	cellbits cellmax cellmin charbits charmax charmin ucharmax __Pawn debug
syn keyword 	cConstant 	true false

syn keyword     cFunction     CreateActor
syn keyword     cFunction     DestroyActor
syn keyword     cFunction     IsActorStreamedIn
syn keyword     cFunction     SetActorVirtualWorld
syn keyword     cFunction     GetActorVirtualWorld
syn keyword     cFunction     ApplyActorAnimation
syn keyword     cFunction     ClearActorAnimations
syn keyword     cFunction     SetActorPos
syn keyword     cFunction     GetActorPos
syn keyword     cFunction     SetActorFacingAngle
syn keyword     cFunction     GetActorFacingAngle
syn keyword     cFunction     SetActorHealth
syn keyword     cFunction     GetActorHealth
syn keyword     cFunction     SetActorInvulnerable
syn keyword     cFunction     IsActorInvulnerable
syn keyword     cFunction     IsValidActor
syn keyword     cFunction     HTTP
syn keyword     cFunction     print
syn keyword     cFunction     printf
syn keyword     cFunction     format
syn keyword     cFunction     SetTimer
syn keyword     cFunction     KillTimer
syn keyword     cFunction     GetTickCount
syn keyword     cFunction     asin
syn keyword     cFunction     acos
syn keyword     cFunction     atan
syn keyword     cFunction     atan2
syn keyword     cFunction     SendChat
syn keyword     cFunction     SendCommand
syn keyword     cFunction     GetPlayerState
syn keyword     cFunction     GetPlayerPos
syn keyword     cFunction     GetPlayerVehicleID
syn keyword     cFunction     GetPlayerArmedWeapon
syn keyword     cFunction     GetPlayerHealth
syn keyword     cFunction     GetPlayerArmour
syn keyword     cFunction     GetPlayerSpecialAction
syn keyword     cFunction     IsPlayerStreamedIn
syn keyword     cFunction     IsVehicleStreamedIn
syn keyword     cFunction     GetPlayerKeys
syn keyword     cFunction     GetPlayerFacingAngle
syn keyword     cFunction     GetMyPos
syn keyword     cFunction     SetMyPos
syn keyword     cFunction     GetMyFacingAngle
syn keyword     cFunction     SetMyFacingAngle
syn keyword     cFunction     GetDistanceFromMeToPoint
syn keyword     cFunction     IsPlayerInRangeOfPoint
syn keyword     cFunction     GetPlayerName
syn keyword     cFunction     IsPlayerConnected
syn keyword     cFunction     StartRecordingPlayback
syn keyword     cFunction     StopRecordingPlayback
syn keyword     cFunction     PauseRecordingPlayback
syn keyword     cFunction     ResumeRecordingPlayback
syn keyword     cFunction     CreateObject
syn keyword     cFunction     AttachObjectToVehicle
syn keyword     cFunction     AttachObjectToObject
syn keyword     cFunction     AttachObjectToPlayer
syn keyword     cFunction     SetObjectPos
syn keyword     cFunction     GetObjectPos
syn keyword     cFunction     SetObjectRot
syn keyword     cFunction     GetObjectRot
syn keyword     cFunction     GetObjectModel
syn keyword     cFunction     SetObjectNoCameraCol
syn keyword     cFunction     IsValidObject
syn keyword     cFunction     DestroyObject
syn keyword     cFunction     MoveObject
syn keyword     cFunction     StopObject
syn keyword     cFunction     IsObjectMoving
syn keyword     cFunction     EditObject
syn keyword     cFunction     EditPlayerObject
syn keyword     cFunction     SelectObject
syn keyword     cFunction     CancelEdit
syn keyword     cFunction     CreatePlayerObject
syn keyword     cFunction     AttachPlayerObjectToVehicle
syn keyword     cFunction     SetPlayerObjectPos
syn keyword     cFunction     GetPlayerObjectPos
syn keyword     cFunction     SetPlayerObjectRot
syn keyword     cFunction     GetPlayerObjectRot
syn keyword     cFunction     GetPlayerObjectModel
syn keyword     cFunction     SetPlayerObjectNoCameraCol
syn keyword     cFunction     IsValidPlayerObject
syn keyword     cFunction     DestroyPlayerObject
syn keyword     cFunction     MovePlayerObject
syn keyword     cFunction     StopPlayerObject
syn keyword     cFunction     IsPlayerObjectMoving
syn keyword     cFunction     AttachPlayerObjectToPlayer
syn keyword     cFunction     SetObjectMaterial
syn keyword     cFunction     SetPlayerObjectMaterial
syn keyword     cFunction     SetObjectMaterialText
syn keyword     cFunction     SetPlayerObjectMaterialText
syn keyword     cFunction     SetObjectsDefaultCameraCol
syn keyword     cFunction     SetSpawnInfo
syn keyword     cFunction     SpawnPlayer
syn keyword     cFunction     SetPlayerPos
syn keyword     cFunction     SetPlayerPosFindZ
syn keyword     cFunction     GetPlayerPos
syn keyword     cFunction     SetPlayerFacingAngle
syn keyword     cFunction     GetPlayerFacingAngle
syn keyword     cFunction     IsPlayerInRangeOfPoint
syn keyword     cFunction     GetPlayerDistanceFromPoint
syn keyword     cFunction     IsPlayerStreamedIn
syn keyword     cFunction     SetPlayerInterior
syn keyword     cFunction     GetPlayerInterior
syn keyword     cFunction     SetPlayerHealth
syn keyword     cFunction     GetPlayerHealth
syn keyword     cFunction     SetPlayerArmour
syn keyword     cFunction     GetPlayerArmour
syn keyword     cFunction     SetPlayerAmmo
syn keyword     cFunction     GetPlayerAmmo
syn keyword     cFunction     GetPlayerWeaponState
syn keyword     cFunction     GetPlayerTargetPlayer
syn keyword     cFunction     GetPlayerTargetActor
syn keyword     cFunction     SetPlayerTeam
syn keyword     cFunction     GetPlayerTeam
syn keyword     cFunction     SetPlayerScore
syn keyword     cFunction     GetPlayerScore
syn keyword     cFunction     GetPlayerDrunkLevel
syn keyword     cFunction     SetPlayerDrunkLevel
syn keyword     cFunction     SetPlayerColor
syn keyword     cFunction     GetPlayerColor
syn keyword     cFunction     SetPlayerSkin
syn keyword     cFunction     GetPlayerSkin
syn keyword     cFunction     GivePlayerWeapon
syn keyword     cFunction     ResetPlayerWeapons
syn keyword     cFunction     SetPlayerArmedWeapon
syn keyword     cFunction     GetPlayerWeaponData
syn keyword     cFunction     GivePlayerMoney
syn keyword     cFunction     ResetPlayerMoney
syn keyword     cFunction     SetPlayerName
syn keyword     cFunction     GetPlayerMoney
syn keyword     cFunction     GetPlayerState
syn keyword     cFunction     GetPlayerIp
syn keyword     cFunction     GetPlayerPing
syn keyword     cFunction     GetPlayerWeapon
syn keyword     cFunction     GetPlayerKeys
syn keyword     cFunction     GetPlayerName
syn keyword     cFunction     SetPlayerTime
syn keyword     cFunction     GetPlayerTime
syn keyword     cFunction     TogglePlayerClock
syn keyword     cFunction     SetPlayerWeather
syn keyword     cFunction     ForceClassSelection
syn keyword     cFunction     SetPlayerWantedLevel
syn keyword     cFunction     GetPlayerWantedLevel
syn keyword     cFunction     SetPlayerFightingStyle
syn keyword     cFunction     GetPlayerFightingStyle
syn keyword     cFunction     SetPlayerVelocity
syn keyword     cFunction     GetPlayerVelocity
syn keyword     cFunction     PlayCrimeReportForPlayer
syn keyword     cFunction     PlayAudioStreamForPlayer
syn keyword     cFunction     StopAudioStreamForPlayer
syn keyword     cFunction     SetPlayerShopName
syn keyword     cFunction     SetPlayerSkillLevel
syn keyword     cFunction     GetPlayerSurfingVehicleID
syn keyword     cFunction     GetPlayerSurfingObjectID
syn keyword     cFunction     RemoveBuildingForPlayer
syn keyword     cFunction     GetPlayerLastShotVectors
syn keyword     cFunction     SetPlayerAttachedObject
syn keyword     cFunction     RemovePlayerAttachedObject
syn keyword     cFunction     IsPlayerAttachedObjectSlotUsed
syn keyword     cFunction     EditAttachedObject
syn keyword     cFunction     CreatePlayerTextDraw
syn keyword     cFunction     PlayerTextDrawDestroy
syn keyword     cFunction     PlayerTextDrawLetterSize
syn keyword     cFunction     PlayerTextDrawTextSize
syn keyword     cFunction     PlayerTextDrawAlignment
syn keyword     cFunction     PlayerTextDrawColor
syn keyword     cFunction     PlayerTextDrawUseBox
syn keyword     cFunction     PlayerTextDrawBoxColor
syn keyword     cFunction     PlayerTextDrawSetShadow
syn keyword     cFunction     PlayerTextDrawSetOutline
syn keyword     cFunction     PlayerTextDrawBackgroundColor
syn keyword     cFunction     PlayerTextDrawFont
syn keyword     cFunction     PlayerTextDrawSetProportional
syn keyword     cFunction     PlayerTextDrawSetSelectable
syn keyword     cFunction     PlayerTextDrawShow
syn keyword     cFunction     PlayerTextDrawHide
syn keyword     cFunction     PlayerTextDrawSetString
syn keyword     cFunction     PlayerTextDrawSetPreviewModel
syn keyword     cFunction     PlayerTextDrawSetPreviewRot
syn keyword     cFunction     PlayerTextDrawSetPreviewVehCol
syn keyword     cFunction     SetPVarInt
syn keyword     cFunction     GetPVarInt
syn keyword     cFunction     SetPVarString
syn keyword     cFunction     GetPVarString
syn keyword     cFunction     SetPVarFloat
syn keyword     cFunction     GetPVarFloat
syn keyword     cFunction     DeletePVar
syn keyword     cFunction     GetPVarsUpperIndex
syn keyword     cFunction     GetPVarNameAtIndex
syn keyword     cFunction     GetPVarType
syn keyword     cFunction     SetPlayerChatBubble
syn keyword     cFunction     PutPlayerInVehicle
syn keyword     cFunction     GetPlayerVehicleID
syn keyword     cFunction     GetPlayerVehicleSeat
syn keyword     cFunction     RemovePlayerFromVehicle
syn keyword     cFunction     TogglePlayerControllable
syn keyword     cFunction     PlayerPlaySound
syn keyword     cFunction     ApplyAnimation
syn keyword     cFunction     ClearAnimations
syn keyword     cFunction     GetPlayerAnimationIndex
syn keyword     cFunction     GetAnimationName
syn keyword     cFunction     GetPlayerSpecialAction
syn keyword     cFunction     SetPlayerSpecialAction
syn keyword     cFunction     DisableRemoteVehicleCollisions
syn keyword     cFunction     SetPlayerCheckpoint
syn keyword     cFunction     DisablePlayerCheckpoint
syn keyword     cFunction     SetPlayerRaceCheckpoint
syn keyword     cFunction     DisablePlayerRaceCheckpoint
syn keyword     cFunction     SetPlayerWorldBounds
syn keyword     cFunction     SetPlayerMarkerForPlayer
syn keyword     cFunction     ShowPlayerNameTagForPlayer
syn keyword     cFunction     SetPlayerMapIcon
syn keyword     cFunction     RemovePlayerMapIcon
syn keyword     cFunction     AllowPlayerTeleport
syn keyword     cFunction     SetPlayerCameraPos
syn keyword     cFunction     SetPlayerCameraLookAt
syn keyword     cFunction     SetCameraBehindPlayer
syn keyword     cFunction     GetPlayerCameraPos
syn keyword     cFunction     GetPlayerCameraFrontVector
syn keyword     cFunction     GetPlayerCameraMode
syn keyword     cFunction     EnablePlayerCameraTarget
syn keyword     cFunction     GetPlayerCameraTargetObject
syn keyword     cFunction     GetPlayerCameraTargetVehicle
syn keyword     cFunction     GetPlayerCameraTargetPlayer
syn keyword     cFunction     GetPlayerCameraTargetActor
syn keyword     cFunction     GetPlayerCameraAspectRatio
syn keyword     cFunction     GetPlayerCameraZoom
syn keyword     cFunction     AttachCameraToObject
syn keyword     cFunction     AttachCameraToPlayerObject
syn keyword     cFunction     InterpolateCameraPos
syn keyword     cFunction     InterpolateCameraLookAt
syn keyword     cFunction     IsPlayerConnected
syn keyword     cFunction     IsPlayerInVehicle
syn keyword     cFunction     IsPlayerInAnyVehicle
syn keyword     cFunction     IsPlayerInCheckpoint
syn keyword     cFunction     IsPlayerInRaceCheckpoint
syn keyword     cFunction     SetPlayerVirtualWorld
syn keyword     cFunction     GetPlayerVirtualWorld
syn keyword     cFunction     EnableStuntBonusForPlayer
syn keyword     cFunction     EnableStuntBonusForAll
syn keyword     cFunction     TogglePlayerSpectating
syn keyword     cFunction     PlayerSpectatePlayer
syn keyword     cFunction     PlayerSpectateVehicle
syn keyword     cFunction     StartRecordingPlayerData
syn keyword     cFunction     StopRecordingPlayerData
syn keyword     cFunction     SelectTextDraw
syn keyword     cFunction     CancelSelectTextDraw
syn keyword     cFunction     CreateExplosionForPlayer
syn keyword     cFunction     print
syn keyword     cFunction     printf
syn keyword     cFunction     format
syn keyword     cFunction     SendClientMessage
syn keyword     cFunction     SendClientMessageToAll
syn keyword     cFunction     SendPlayerMessageToPlayer
syn keyword     cFunction     SendPlayerMessageToAll
syn keyword     cFunction     SendDeathMessage
syn keyword     cFunction     SendDeathMessageToPlayer
syn keyword     cFunction     GameTextForAll
syn keyword     cFunction     GameTextForPlayer
syn keyword     cFunction     SetTimer
syn keyword     cFunction     SetTimerEx
syn keyword     cFunction     KillTimer
syn keyword     cFunction     GetTickCount
syn keyword     cFunction     GetMaxPlayers
syn keyword     cFunction     CallRemoteFunction
syn keyword     cFunction     CallLocalFunction
syn keyword     cFunction     VectorSize
syn keyword     cFunction     asin
syn keyword     cFunction     acos
syn keyword     cFunction     atan
syn keyword     cFunction     atan2
syn keyword     cFunction     GetPlayerPoolSize
syn keyword     cFunction     GetVehiclePoolSize
syn keyword     cFunction     GetActorPoolSize
syn keyword     cFunction     SHA256_PassHash
syn keyword     cFunction     SetSVarInt
syn keyword     cFunction     GetSVarInt
syn keyword     cFunction     SetSVarString
syn keyword     cFunction     GetSVarString
syn keyword     cFunction     SetSVarFloat
syn keyword     cFunction     GetSVarFloat
syn keyword     cFunction     DeleteSVar
syn keyword     cFunction     GetSVarsUpperIndex
syn keyword     cFunction     GetSVarNameAtIndex
syn keyword     cFunction     GetSVarType
syn keyword     cFunction     SetGameModeText
syn keyword     cFunction     SetTeamCount
syn keyword     cFunction     AddPlayerClass
syn keyword     cFunction     AddPlayerClassEx
syn keyword     cFunction     AddStaticVehicle
syn keyword     cFunction     AddStaticVehicleEx
syn keyword     cFunction     AddStaticPickup
syn keyword     cFunction     CreatePickup
syn keyword     cFunction     DestroyPickup
syn keyword     cFunction     ShowNameTags
syn keyword     cFunction     ShowPlayerMarkers
syn keyword     cFunction     GameModeExit
syn keyword     cFunction     SetWorldTime
syn keyword     cFunction     GetWeaponName
syn keyword     cFunction     EnableTirePopping
syn keyword     cFunction     EnableVehicleFriendlyFire
syn keyword     cFunction     AllowInteriorWeapons
syn keyword     cFunction     SetWeather
syn keyword     cFunction     SetGravity
syn keyword     cFunction     AllowAdminTeleport
syn keyword     cFunction     SetDeathDropAmount
syn keyword     cFunction     CreateExplosion
syn keyword     cFunction     EnableZoneNames
syn keyword     cFunction     UsePlayerPedAnims
syn keyword     cFunction     DisableInteriorEnterExits
syn keyword     cFunction     SetNameTagDrawDistance
syn keyword     cFunction     DisableNameTagLOS
syn keyword     cFunction     LimitGlobalChatRadius
syn keyword     cFunction     LimitPlayerMarkerRadius
syn keyword     cFunction     ConnectNPC
syn keyword     cFunction     IsPlayerNPC
syn keyword     cFunction     IsPlayerAdmin
syn keyword     cFunction     Kick
syn keyword     cFunction     Ban
syn keyword     cFunction     BanEx
syn keyword     cFunction     SendRconCommand
syn keyword     cFunction     GetPlayerNetworkStats
syn keyword     cFunction     GetNetworkStats
syn keyword     cFunction     GetPlayerVersion
syn keyword     cFunction     BlockIpAddress
syn keyword     cFunction     UnBlockIpAddress
syn keyword     cFunction     GetServerVarAsString
syn keyword     cFunction     GetServerVarAsInt
syn keyword     cFunction     GetServerVarAsBool
syn keyword     cFunction     GetConsoleVarAsString
syn keyword     cFunction     GetConsoleVarAsInt
syn keyword     cFunction     GetConsoleVarAsBool
syn keyword     cFunction     GetServerTickRate
syn keyword     cFunction     NetStats_GetConnectedTime
syn keyword     cFunction     NetStats_MessagesReceived
syn keyword     cFunction     NetStats_BytesReceived
syn keyword     cFunction     NetStats_MessagesSent
syn keyword     cFunction     NetStats_BytesSent
syn keyword     cFunction     NetStats_MessagesRecvPerSecond
syn keyword     cFunction     NetStats_PacketLossPercent
syn keyword     cFunction     NetStats_ConnectionStatus
syn keyword     cFunction     NetStats_GetIpPort
syn keyword     cFunction     CreateMenu
syn keyword     cFunction     DestroyMenu
syn keyword     cFunction     AddMenuItem
syn keyword     cFunction     SetMenuColumnHeader
syn keyword     cFunction     ShowMenuForPlayer
syn keyword     cFunction     HideMenuForPlayer
syn keyword     cFunction     IsValidMenu
syn keyword     cFunction     DisableMenu
syn keyword     cFunction     DisableMenuRow
syn keyword     cFunction     GetPlayerMenu
syn keyword     cFunction     TextDrawCreate
syn keyword     cFunction     TextDrawDestroy
syn keyword     cFunction     TextDrawLetterSize
syn keyword     cFunction     TextDrawTextSize
syn keyword     cFunction     TextDrawAlignment
syn keyword     cFunction     TextDrawColor
syn keyword     cFunction     TextDrawUseBox
syn keyword     cFunction     TextDrawBoxColor
syn keyword     cFunction     TextDrawSetShadow
syn keyword     cFunction     TextDrawSetOutline
syn keyword     cFunction     TextDrawBackgroundColor
syn keyword     cFunction     TextDrawFont
syn keyword     cFunction     TextDrawSetProportional
syn keyword     cFunction     TextDrawSetSelectable
syn keyword     cFunction     TextDrawShowForPlayer
syn keyword     cFunction     TextDrawHideForPlayer
syn keyword     cFunction     TextDrawShowForAll
syn keyword     cFunction     TextDrawHideForAll
syn keyword     cFunction     TextDrawSetString
syn keyword     cFunction     TextDrawSetPreviewModel
syn keyword     cFunction     TextDrawSetPreviewRot
syn keyword     cFunction     TextDrawSetPreviewVehCol
syn keyword     cFunction     GangZoneCreate
syn keyword     cFunction     GangZoneDestroy
syn keyword     cFunction     GangZoneShowForPlayer
syn keyword     cFunction     GangZoneShowForAll
syn keyword     cFunction     GangZoneHideForPlayer
syn keyword     cFunction     GangZoneHideForAll
syn keyword     cFunction     GangZoneFlashForPlayer
syn keyword     cFunction     GangZoneFlashForAll
syn keyword     cFunction     GangZoneStopFlashForPlayer
syn keyword     cFunction     GangZoneStopFlashForAll
syn keyword     cFunction     Create3DTextLabel
syn keyword     cFunction     Delete3DTextLabel
syn keyword     cFunction     Attach3DTextLabelToPlayer
syn keyword     cFunction     Attach3DTextLabelToVehicle
syn keyword     cFunction     Update3DTextLabelText
syn keyword     cFunction     CreatePlayer3DTextLabel
syn keyword     cFunction     DeletePlayer3DTextLabel
syn keyword     cFunction     UpdatePlayer3DTextLabelText
syn keyword     cFunction     ShowPlayerDialog
syn keyword     cFunction     db_open
syn keyword     cFunction     db_close
syn keyword     cFunction     db_query
syn keyword     cFunction     db_free_result
syn keyword     cFunction     db_num_rows
syn keyword     cFunction     db_next_row
syn keyword     cFunction     db_num_fields
syn keyword     cFunction     db_field_name
syn keyword     cFunction     db_get_field
syn keyword     cFunction     db_get_field_int
syn keyword     cFunction     db_get_field_float
syn keyword     cFunction     db_get_field_assoc
syn keyword     cFunction     db_get_field_assoc_int
syn keyword     cFunction     db_get_field_assoc_float
syn keyword     cFunction     db_get_mem_handle
syn keyword     cFunction     db_get_result_mem_handle
syn keyword     cFunction     db_debug_openfiles
syn keyword     cFunction     db_debug_openresults
syn keyword     cFunction     CreateVehicle
syn keyword     cFunction     DestroyVehicle
syn keyword     cFunction     IsVehicleStreamedIn
syn keyword     cFunction     GetVehiclePos
syn keyword     cFunction     SetVehiclePos
syn keyword     cFunction     GetVehicleZAngle
syn keyword     cFunction     GetVehicleRotationQuat
syn keyword     cFunction     GetVehicleDistanceFromPoint
syn keyword     cFunction     SetVehicleZAngle
syn keyword     cFunction     SetVehicleParamsForPlayer
syn keyword     cFunction     ManualVehicleEngineAndLights
syn keyword     cFunction     SetVehicleParamsEx
syn keyword     cFunction     GetVehicleParamsEx
syn keyword     cFunction     GetVehicleParamsSirenState
syn keyword     cFunction     SetVehicleParamsCarDoors
syn keyword     cFunction     GetVehicleParamsCarDoors
syn keyword     cFunction     SetVehicleParamsCarWindows
syn keyword     cFunction     GetVehicleParamsCarWindows
syn keyword     cFunction     SetVehicleToRespawn
syn keyword     cFunction     LinkVehicleToInterior
syn keyword     cFunction     AddVehicleComponent
syn keyword     cFunction     RemoveVehicleComponent
syn keyword     cFunction     ChangeVehicleColor
syn keyword     cFunction     ChangeVehiclePaintjob
syn keyword     cFunction     SetVehicleHealth
syn keyword     cFunction     GetVehicleHealth
syn keyword     cFunction     AttachTrailerToVehicle
syn keyword     cFunction     DetachTrailerFromVehicle
syn keyword     cFunction     IsTrailerAttachedToVehicle
syn keyword     cFunction     GetVehicleTrailer
syn keyword     cFunction     SetVehicleNumberPlate
syn keyword     cFunction     GetVehicleModel
syn keyword     cFunction     GetVehicleComponentInSlot
syn keyword     cFunction     GetVehicleComponentType
syn keyword     cFunction     RepairVehicle
syn keyword     cFunction     GetVehicleVelocity
syn keyword     cFunction     SetVehicleVelocity
syn keyword     cFunction     SetVehicleAngularVelocity
syn keyword     cFunction     GetVehicleDamageStatus
syn keyword     cFunction     UpdateVehicleDamageStatus
syn keyword     cFunction     GetVehicleModelInfo
syn keyword     cFunction     SetVehicleVirtualWorld
syn keyword     cFunction     GetVehicleVirtualWorld
syn keyword     cFunction     heapspace
syn keyword     cFunction     funcidx
syn keyword     cFunction     numargs
syn keyword     cFunction     getarg
syn keyword     cFunction     setarg
syn keyword     cFunction     tolower
syn keyword     cFunction     toupper
syn keyword     cFunction     swapchars
syn keyword     cFunction     random
syn keyword     cFunction     min
syn keyword     cFunction     max
syn keyword     cFunction     clamp
syn keyword     cFunction     getproperty
syn keyword     cFunction     setproperty
syn keyword     cFunction     deleteproperty
syn keyword     cFunction     existproperty
syn keyword     cFunction     sendstring
syn keyword     cFunction     sendpacket
syn keyword     cFunction     listenport
syn keyword     cFunction     fopen
syn keyword     cFunction     fclose
syn keyword     cFunction     ftemp
syn keyword     cFunction     fremove
syn keyword     cFunction     fwrite
syn keyword     cFunction     fread
syn keyword     cFunction     fputchar
syn keyword     cFunction     fgetchar
syn keyword     cFunction     fblockwrite
syn keyword     cFunction     fblockread
syn keyword     cFunction     fseek
syn keyword     cFunction     flength
syn keyword     cFunction     fexist
syn keyword     cFunction     fmatch
syn keyword     cFunction     float
syn keyword     cFunction     floatstr
syn keyword     cFunction     floatmul
syn keyword     cFunction     floatdiv
syn keyword     cFunction     floatadd
syn keyword     cFunction     floatsub
syn keyword     cFunction     floatfract
syn keyword     cFunction     floatround
syn keyword     cFunction     floatcmp
syn keyword     cFunction     floatsqroot
syn keyword     cFunction     floatpower
syn keyword     cFunction     floatlog
syn keyword     cFunction     floatsin
syn keyword     cFunction     floatcos
syn keyword     cFunction     floattan
syn keyword     cFunction     floatabs
syn keyword     cFunction     strlen
syn keyword     cFunction     strpack
syn keyword     cFunction     strunpack
syn keyword     cFunction     strcat
syn keyword     cFunction     strmid
syn keyword     cFunction     strcmp
syn keyword     cFunction     strfind
syn keyword     cFunction     strval
syn keyword     cFunction     valstr
syn keyword     cFunction     uudecode
syn keyword     cFunction     uuencode
syn keyword     cFunction     memcpy
syn keyword     cFunction     gettime
syn keyword     cFunction     getdate
syn keyword     cFunction     tickcount


" version.inc
syn keyword	cConstant	SOURCEMOD_V_TAG SOURCEMOD_V_REV SOURCEMOD_V_CSET SOURCEMOD_V_MAJOR
syn keyword	cConstant	SOURCEMOD_V_MINOR SOURCEMOD_V_RELEASE SOURCEMOD_VERSION

syn keyword     cConstant     HTTP_GET
syn keyword     cConstant     HTTP_POST
syn keyword     cConstant     HTTP_HEAD
syn keyword     cConstant     HTTP_ERROR_BAD_HOST
syn keyword     cConstant     HTTP_ERROR_NO_SOCKET
syn keyword     cConstant     HTTP_ERROR_CANT_CONNECT
syn keyword     cConstant     HTTP_ERROR_CANT_WRITE
syn keyword     cConstant     HTTP_ERROR_CONTENT_TOO_BIG
syn keyword     cConstant     HTTP_ERROR_MALFORMED_RESPONSE
syn keyword     cConstant     PLAYER_RECORDING_TYPE_NONE
syn keyword     cConstant     PLAYER_RECORDING_TYPE_DRIVER
syn keyword     cConstant     PLAYER_RECORDING_TYPE_ONFOOT
syn keyword     cConstant     PLAYER_STATE_NONE
syn keyword     cConstant     PLAYER_STATE_ONFOOT
syn keyword     cConstant     PLAYER_STATE_DRIVER
syn keyword     cConstant     PLAYER_STATE_PASSENGER
syn keyword     cConstant     PLAYER_STATE_WASTED
syn keyword     cConstant     PLAYER_STATE_SPAWNED
syn keyword     cConstant     PLAYER_STATE_SPECTATING
syn keyword     cConstant     MAX_PLAYER_NAME
syn keyword     cConstant     MAX_PLAYERS
syn keyword     cConstant     MAX_VEHICLES
syn keyword     cConstant     INVALID_PLAYER_ID
syn keyword     cConstant     INVALID_VEHICLE_ID
syn keyword     cConstant     NO_TEAM
syn keyword     cConstant     MAX_OBJECTS
syn keyword     cConstant     INVALID_OBJECT_ID
syn keyword     cConstant     MAX_GANG_ZONES
syn keyword     cConstant     MAX_TEXT_DRAWS
syn keyword     cConstant     MAX_MENUS
syn keyword     cConstant     INVALID_MENU
syn keyword     cConstant     INVALID_TEXT_DRAW
syn keyword     cConstant     INVALID_GANG_ZONE
syn keyword     cConstant     WEAPON_BRASSKNUCKLE
syn keyword     cConstant     WEAPON_GOLFCLUB
syn keyword     cConstant     WEAPON_NITESTICK
syn keyword     cConstant     WEAPON_KNIFE
syn keyword     cConstant     WEAPON_BAT
syn keyword     cConstant     WEAPON_SHOVEL
syn keyword     cConstant     WEAPON_POOLSTICK
syn keyword     cConstant     WEAPON_KATANA
syn keyword     cConstant     WEAPON_CHAINSAW
syn keyword     cConstant     WEAPON_DILDO
syn keyword     cConstant     WEAPON_DILDO2
syn keyword     cConstant     WEAPON_VIBRATOR
syn keyword     cConstant     WEAPON_VIBRATOR2
syn keyword     cConstant     WEAPON_FLOWER
syn keyword     cConstant     WEAPON_CANE
syn keyword     cConstant     WEAPON_GRENADE
syn keyword     cConstant     WEAPON_TEARGAS
syn keyword     cConstant     WEAPON_MOLTOV
syn keyword     cConstant     WEAPON_COLT45
syn keyword     cConstant     WEAPON_SILENCED
syn keyword     cConstant     WEAPON_DEAGLE
syn keyword     cConstant     WEAPON_SHOTGUN
syn keyword     cConstant     WEAPON_SAWEDOFF
syn keyword     cConstant     WEAPON_SHOTGSPA
syn keyword     cConstant     WEAPON_UZI
syn keyword     cConstant     WEAPON_MP5
syn keyword     cConstant     WEAPON_AK47
syn keyword     cConstant     WEAPON_M4
syn keyword     cConstant     WEAPON_TEC9
syn keyword     cConstant     WEAPON_RIFLE
syn keyword     cConstant     WEAPON_SNIPER
syn keyword     cConstant     WEAPON_ROCKETLAUNCHER
syn keyword     cConstant     WEAPON_HEATSEEKER
syn keyword     cConstant     WEAPON_FLAMETHROWER
syn keyword     cConstant     WEAPON_MINIGUN
syn keyword     cConstant     WEAPON_SATCHEL
syn keyword     cConstant     WEAPON_BOMB
syn keyword     cConstant     WEAPON_SPRAYCAN
syn keyword     cConstant     WEAPON_FIREEXTINGUISHER
syn keyword     cConstant     WEAPON_CAMERA
syn keyword     cConstant     WEAPON_PARACHUTE
syn keyword     cConstant     WEAPON_VEHICLE
syn keyword     cConstant     WEAPON_DROWN
syn keyword     cConstant     WEAPON_COLLISION
syn keyword     cConstant     KEY_ACTION
syn keyword     cConstant     KEY_CROUCH
syn keyword     cConstant     KEY_FIRE
syn keyword     cConstant     KEY_SPRINT
syn keyword     cConstant     KEY_SECONDARY_ATTACK
syn keyword     cConstant     KEY_JUMP
syn keyword     cConstant     KEY_LOOK_RIGHT
syn keyword     cConstant     KEY_HANDBRAKE
syn keyword     cConstant     KEY_LOOK_LEFT
syn keyword     cConstant     KEY_SUBMISSION
syn keyword     cConstant     KEY_LOOK_BEHIND
syn keyword     cConstant     KEY_WALK
syn keyword     cConstant     KEY_ANALOG_UP
syn keyword     cConstant     KEY_ANALOG_DOWN
syn keyword     cConstant     KEY_ANALOG_RIGHT
syn keyword     cConstant     KEY_ANALOG_LEFT
syn keyword     cConstant     KEY_UP
syn keyword     cConstant     KEY_DOWN
syn keyword     cConstant     KEY_LEFT
syn keyword     cConstant     KEY_RIGHT
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_32
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_64
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_64
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_128
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_128
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_128
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_256
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_256
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_256
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_256
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_512
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_512
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_512
syn keyword     cConstant     OBJECT_MATERIAL_SIZE_512
syn keyword     cConstant     OBJECT_MATERIAL_TEXT_ALIGN_LEFT
syn keyword     cConstant     OBJECT_MATERIAL_TEXT_ALIGN_CENTER
syn keyword     cConstant     OBJECT_MATERIAL_TEXT_ALIGN_RIGHT
syn keyword     cConstant     SPECIAL_ACTION_NONE
syn keyword     cConstant     SPECIAL_ACTION_DUCK
syn keyword     cConstant     SPECIAL_ACTION_USEJETPACK
syn keyword     cConstant     SPECIAL_ACTION_ENTER_VEHICLE
syn keyword     cConstant     SPECIAL_ACTION_EXIT_VEHICLE
syn keyword     cConstant     SPECIAL_ACTION_DANCE1
syn keyword     cConstant     SPECIAL_ACTION_DANCE2
syn keyword     cConstant     SPECIAL_ACTION_DANCE3
syn keyword     cConstant     SPECIAL_ACTION_DANCE4
syn keyword     cConstant     SPECIAL_ACTION_HANDSUP
syn keyword     cConstant     SPECIAL_ACTION_USECELLPHONE
syn keyword     cConstant     SPECIAL_ACTION_SITTING
syn keyword     cConstant     SPECIAL_ACTION_STOPUSECELLPHONE
syn keyword     cConstant     SPECIAL_ACTION_DRINK_BEER
syn keyword     cConstant     SPECIAL_ACTION_SMOKE_CIGGY
syn keyword     cConstant     SPECIAL_ACTION_DRINK_WINE
syn keyword     cConstant     SPECIAL_ACTION_DRINK_SPRUNK
syn keyword     cConstant     SPECIAL_ACTION_CUFFED
syn keyword     cConstant     SPECIAL_ACTION_CARRY
syn keyword     cConstant     FIGHT_STYLE_NORMAL
syn keyword     cConstant     FIGHT_STYLE_BOXING
syn keyword     cConstant     FIGHT_STYLE_KUNGFU
syn keyword     cConstant     FIGHT_STYLE_KNEEHEAD
syn keyword     cConstant     FIGHT_STYLE_GRABKICK
syn keyword     cConstant     FIGHT_STYLE_ELBOW
syn keyword     cConstant     WEAPONSKILL_PISTOL
syn keyword     cConstant     WEAPONSKILL_PISTOL_SILENCED
syn keyword     cConstant     WEAPONSKILL_DESERT_EAGLE
syn keyword     cConstant     WEAPONSKILL_SHOTGUN
syn keyword     cConstant     WEAPONSKILL_SAWNOFF_SHOTGUN
syn keyword     cConstant     WEAPONSKILL_SPAS12_SHOTGUN
syn keyword     cConstant     WEAPONSKILL_MICRO_UZI
syn keyword     cConstant     WEAPONSKILL_MP5
syn keyword     cConstant     WEAPONSKILL_AK47
syn keyword     cConstant     WEAPONSKILL_M4
syn keyword     cConstant     WEAPONSKILL_SNIPERRIFLE
syn keyword     cConstant     WEAPONSTATE_UNKNOWN
syn keyword     cConstant     WEAPONSTATE_NO_BULLETS
syn keyword     cConstant     WEAPONSTATE_LAST_BULLET
syn keyword     cConstant     WEAPONSTATE_MORE_BULLETS
syn keyword     cConstant     WEAPONSTATE_RELOADING
syn keyword     cConstant     MAX_PLAYER_ATTACHED_OBJECTS
syn keyword     cConstant     PLAYER_VARTYPE_NONE
syn keyword     cConstant     PLAYER_VARTYPE_INT
syn keyword     cConstant     PLAYER_VARTYPE_STRING
syn keyword     cConstant     PLAYER_VARTYPE_FLOAT
syn keyword     cConstant     MAX_CHATBUBBLE_LENGTH
syn keyword     cConstant     MAPICON_LOCAL
syn keyword     cConstant     MAPICON_GLOBAL
syn keyword     cConstant     MAPICON_LOCAL_CHECKPOINT
syn keyword     cConstant     MAPICON_GLOBAL_CHECKPOINT
syn keyword     cConstant     CAMERA_CUT
syn keyword     cConstant     CAMERA_MOVE
syn keyword     cConstant     SPECTATE_MODE_NORMAL
syn keyword     cConstant     SPECTATE_MODE_FIXED
syn keyword     cConstant     SPECTATE_MODE_SIDE
syn keyword     cConstant     PLAYER_RECORDING_TYPE_NONE
syn keyword     cConstant     PLAYER_RECORDING_TYPE_DRIVER
syn keyword     cConstant     PLAYER_RECORDING_TYPE_ONFOOT
syn keyword     cConstant     MAX_PLAYER_NAME
syn keyword     cConstant     MAX_PLAYERS
syn keyword     cConstant     MAX_VEHICLES
syn keyword     cConstant     MAX_ACTORS
syn keyword     cConstant     INVALID_PLAYER_ID
syn keyword     cConstant     INVALID_VEHICLE_ID
syn keyword     cConstant     INVALID_ACTOR_ID
syn keyword     cConstant     NO_TEAM
syn keyword     cConstant     MAX_OBJECTS
syn keyword     cConstant     INVALID_OBJECT_ID
syn keyword     cConstant     MAX_GANG_ZONES
syn keyword     cConstant     MAX_TEXT_DRAWS
syn keyword     cConstant     MAX_PLAYER_TEXT_DRAWS
syn keyword     cConstant     MAX_MENUS
syn keyword     cConstant     MAX_3DTEXT_GLOBAL
syn keyword     cConstant     MAX_3DTEXT_PLAYER
syn keyword     cConstant     MAX_PICKUPS
syn keyword     cConstant     INVALID_MENU
syn keyword     cConstant     INVALID_TEXT_DRAW
syn keyword     cConstant     INVALID_GANG_ZONE
syn keyword     cConstant     INVALID_3DTEXT_ID
syn keyword     cConstant     SERVER_VARTYPE_NONE
syn keyword     cConstant     SERVER_VARTYPE_INT
syn keyword     cConstant     SERVER_VARTYPE_STRING
syn keyword     cConstant     SERVER_VARTYPE_FLOAT
syn keyword     cConstant     TEXT_DRAW_FONT_SPRITE_DRAW
syn keyword     cConstant     TEXT_DRAW_FONT_MODEL_PREVIEW
syn keyword     cConstant     DIALOG_STYLE_MSGBOX
syn keyword     cConstant     DIALOG_STYLE_INPUT
syn keyword     cConstant     DIALOG_STYLE_LIST
syn keyword     cConstant     DIALOG_STYLE_PASSWORD
syn keyword     cConstant     DIALOG_STYLE_TABLIST
syn keyword     cConstant     DIALOG_STYLE_TABLIST_HEADERS
syn keyword     cConstant     PLAYER_STATE_NONE
syn keyword     cConstant     PLAYER_STATE_ONFOOT
syn keyword     cConstant     PLAYER_STATE_DRIVER
syn keyword     cConstant     PLAYER_STATE_PASSENGER
syn keyword     cConstant     PLAYER_STATE_EXIT_VEHICLE
syn keyword     cConstant     PLAYER_STATE_ENTER_VEHICLE_DRIVER
syn keyword     cConstant     PLAYER_STATE_ENTER_VEHICLE_PASSENGER
syn keyword     cConstant     PLAYER_STATE_WASTED
syn keyword     cConstant     PLAYER_STATE_SPAWNED
syn keyword     cConstant     PLAYER_STATE_SPECTATING
syn keyword     cConstant     PLAYER_MARKERS_MODE_OFF
syn keyword     cConstant     PLAYER_MARKERS_MODE_GLOBAL
syn keyword     cConstant     PLAYER_MARKERS_MODE_STREAMED
syn keyword     cConstant     WEAPON_BRASSKNUCKLE
syn keyword     cConstant     WEAPON_GOLFCLUB
syn keyword     cConstant     WEAPON_NITESTICK
syn keyword     cConstant     WEAPON_KNIFE
syn keyword     cConstant     WEAPON_BAT
syn keyword     cConstant     WEAPON_SHOVEL
syn keyword     cConstant     WEAPON_POOLSTICK
syn keyword     cConstant     WEAPON_KATANA
syn keyword     cConstant     WEAPON_CHAINSAW
syn keyword     cConstant     WEAPON_DILDO
syn keyword     cConstant     WEAPON_DILDO2
syn keyword     cConstant     WEAPON_VIBRATOR
syn keyword     cConstant     WEAPON_VIBRATOR2
syn keyword     cConstant     WEAPON_FLOWER
syn keyword     cConstant     WEAPON_CANE
syn keyword     cConstant     WEAPON_GRENADE
syn keyword     cConstant     WEAPON_TEARGAS
syn keyword     cConstant     WEAPON_MOLTOV
syn keyword     cConstant     WEAPON_COLT45
syn keyword     cConstant     WEAPON_SILENCED
syn keyword     cConstant     WEAPON_DEAGLE
syn keyword     cConstant     WEAPON_SHOTGUN
syn keyword     cConstant     WEAPON_SAWEDOFF
syn keyword     cConstant     WEAPON_SHOTGSPA
syn keyword     cConstant     WEAPON_UZI
syn keyword     cConstant     WEAPON_MP5
syn keyword     cConstant     WEAPON_AK47
syn keyword     cConstant     WEAPON_M4
syn keyword     cConstant     WEAPON_TEC9
syn keyword     cConstant     WEAPON_RIFLE
syn keyword     cConstant     WEAPON_SNIPER
syn keyword     cConstant     WEAPON_ROCKETLAUNCHER
syn keyword     cConstant     WEAPON_HEATSEEKER
syn keyword     cConstant     WEAPON_FLAMETHROWER
syn keyword     cConstant     WEAPON_MINIGUN
syn keyword     cConstant     WEAPON_SATCHEL
syn keyword     cConstant     WEAPON_BOMB
syn keyword     cConstant     WEAPON_SPRAYCAN
syn keyword     cConstant     WEAPON_FIREEXTINGUISHER
syn keyword     cConstant     WEAPON_CAMERA
syn keyword     cConstant     WEAPON_PARACHUTE
syn keyword     cConstant     WEAPON_VEHICLE
syn keyword     cConstant     WEAPON_DROWN
syn keyword     cConstant     WEAPON_COLLISION
syn keyword     cConstant     KEY_ACTION
syn keyword     cConstant     KEY_CROUCH
syn keyword     cConstant     KEY_FIRE
syn keyword     cConstant     KEY_SPRINT
syn keyword     cConstant     KEY_SECONDARY_ATTACK
syn keyword     cConstant     KEY_JUMP
syn keyword     cConstant     KEY_LOOK_RIGHT
syn keyword     cConstant     KEY_HANDBRAKE
syn keyword     cConstant     KEY_LOOK_LEFT
syn keyword     cConstant     KEY_SUBMISSION
syn keyword     cConstant     KEY_LOOK_BEHIND
syn keyword     cConstant     KEY_WALK
syn keyword     cConstant     KEY_ANALOG_UP
syn keyword     cConstant     KEY_ANALOG_DOWN
syn keyword     cConstant     KEY_ANALOG_LEFT
syn keyword     cConstant     KEY_ANALOG_RIGHT
syn keyword     cConstant     KEY_YES
syn keyword     cConstant     KEY_NO
syn keyword     cConstant     KEY_CTRL_BACK
syn keyword     cConstant     KEY_UP
syn keyword     cConstant     KEY_DOWN
syn keyword     cConstant     KEY_LEFT
syn keyword     cConstant     KEY_RIGHT
syn keyword     cConstant     CLICK_SOURCE_SCOREBOARD
syn keyword     cConstant     EDIT_RESPONSE_CANCEL
syn keyword     cConstant     EDIT_RESPONSE_FINAL
syn keyword     cConstant     EDIT_RESPONSE_UPDATE
syn keyword     cConstant     SELECT_OBJECT_GLOBAL_OBJECT
syn keyword     cConstant     SELECT_OBJECT_PLAYER_OBJECT
syn keyword     cConstant     BULLET_HIT_TYPE_NONE
syn keyword     cConstant     BULLET_HIT_TYPE_PLAYER
syn keyword     cConstant     BULLET_HIT_TYPE_VEHICLE
syn keyword     cConstant     BULLET_HIT_TYPE_OBJECT
syn keyword     cConstant     BULLET_HIT_TYPE_PLAYER_OBJECT
syn keyword     cConstant     CARMODTYPE_SPOILER
syn keyword     cConstant     CARMODTYPE_HOOD
syn keyword     cConstant     CARMODTYPE_ROOF
syn keyword     cConstant     CARMODTYPE_SIDESKIRT
syn keyword     cConstant     CARMODTYPE_LAMPS
syn keyword     cConstant     CARMODTYPE_NITRO
syn keyword     cConstant     CARMODTYPE_EXHAUST
syn keyword     cConstant     CARMODTYPE_WHEELS
syn keyword     cConstant     CARMODTYPE_STEREO
syn keyword     cConstant     CARMODTYPE_HYDRAULICS
syn keyword     cConstant     CARMODTYPE_FRONT_BUMPER
syn keyword     cConstant     CARMODTYPE_REAR_BUMPER
syn keyword     cConstant     CARMODTYPE_VENT_RIGHT
syn keyword     cConstant     CARMODTYPE_VENT_LEFT
syn keyword     cConstant     VEHICLE_PARAMS_UNSET
syn keyword     cConstant     VEHICLE_PARAMS_OFF
syn keyword     cConstant     VEHICLE_PARAMS_ON
syn keyword     cConstant     VEHICLE_MODEL_INFO_SIZE
syn keyword     cConstant     VEHICLE_MODEL_INFO_FRONTSEAT
syn keyword     cConstant     VEHICLE_MODEL_INFO_REARSEAT
syn keyword     cConstant     VEHICLE_MODEL_INFO_PETROLCAP
syn keyword     cConstant     VEHICLE_MODEL_INFO_WHEELSFRONT
syn keyword     cConstant     VEHICLE_MODEL_INFO_WHEELSREAR
syn keyword     cConstant     VEHICLE_MODEL_INFO_WHEELSMID
syn keyword     cConstant     VEHICLE_MODEL_INFO_FRONT_BUMPER_Z
syn keyword     cConstant     VEHICLE_MODEL_INFO_REAR_BUMPER_Z

" Forwards
syn keyword     cForward     OnNPCModeInit
syn keyword     cForward     OnNPCModeExit
syn keyword     cForward     OnNPCConnect
syn keyword     cForward     OnNPCDisconnect
syn keyword     cForward     OnNPCSpawn
syn keyword     cForward     OnNPCEnterVehicle
syn keyword     cForward     OnNPCExitVehicle
syn keyword     cForward     OnClientMessage
syn keyword     cForward     OnPlayerDeath
syn keyword     cForward     OnPlayerText
syn keyword     cForward     OnPlayerStreamIn
syn keyword     cForward     OnPlayerStreamOut
syn keyword     cForward     OnVehicleStreamIn
syn keyword     cForward     OnVehicleStreamOut
syn keyword     cForward     OnRecordingPlaybackEnd
syn keyword     cForward     OnGameModeInit
syn keyword     cForward     OnGameModeExit
syn keyword     cForward     OnFilterScriptInit
syn keyword     cForward     OnFilterScriptExit
syn keyword     cForward     OnPlayerConnect
syn keyword     cForward     OnPlayerDisconnect
syn keyword     cForward     OnPlayerSpawn
syn keyword     cForward     OnPlayerDeath
syn keyword     cForward     OnVehicleSpawn
syn keyword     cForward     OnVehicleDeath
syn keyword     cForward     OnPlayerText
syn keyword     cForward     OnPlayerCommandText
syn keyword     cForward     OnPlayerRequestClass
syn keyword     cForward     OnPlayerEnterVehicle
syn keyword     cForward     OnPlayerExitVehicle
syn keyword     cForward     OnPlayerStateChange
syn keyword     cForward     OnPlayerEnterCheckpoint
syn keyword     cForward     OnPlayerLeaveCheckpoint
syn keyword     cForward     OnPlayerEnterRaceCheckpoint
syn keyword     cForward     OnPlayerLeaveRaceCheckpoint
syn keyword     cForward     OnRconCommand
syn keyword     cForward     OnPlayerRequestSpawn
syn keyword     cForward     OnObjectMoved
syn keyword     cForward     OnPlayerObjectMoved
syn keyword     cForward     OnPlayerPickUpPickup
syn keyword     cForward     OnVehicleMod
syn keyword     cForward     OnEnterExitModShop
syn keyword     cForward     OnVehiclePaintjob
syn keyword     cForward     OnVehicleRespray
syn keyword     cForward     OnVehicleDamageStatusUpdate
syn keyword     cForward     OnUnoccupiedVehicleUpdate
syn keyword     cForward     OnPlayerSelectedMenuRow
syn keyword     cForward     OnPlayerExitedMenu
syn keyword     cForward     OnPlayerInteriorChange
syn keyword     cForward     OnPlayerKeyStateChange
syn keyword     cForward     OnRconLoginAttempt
syn keyword     cForward     OnPlayerUpdate
syn keyword     cForward     OnPlayerStreamIn
syn keyword     cForward     OnPlayerStreamOut
syn keyword     cForward     OnVehicleStreamIn
syn keyword     cForward     OnVehicleStreamOut
syn keyword     cForward     OnActorStreamIn
syn keyword     cForward     OnActorStreamOut
syn keyword     cForward     OnDialogResponse
syn keyword     cForward     OnPlayerTakeDamage
syn keyword     cForward     OnPlayerGiveDamage
syn keyword     cForward     OnPlayerGiveDamageActor
syn keyword     cForward     OnPlayerClickMap
syn keyword     cForward     OnPlayerClickTextDraw
syn keyword     cForward     OnPlayerClickPlayerTextDraw
syn keyword     cForward     OnIncomingConnection
syn keyword     cForward     OnTrailerUpdate
syn keyword     cForward     OnVehicleSirenStateChange
syn keyword     cForward     OnPlayerClickPlayer
syn keyword     cForward     OnPlayerSelectObject
syn keyword     cForward     OnPlayerWeaponShot




" Accept %: for # (C99)
syn region      cPreCondit      start="^\s*\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$"  keepend contains=cComment,cCommentL,cCppString,cCharacter,cCppParen,cParenError,cNumbers,cCommentError,cSpaceError
syn match	cPreCondit	display "^\s*\(%:\|#\)\s*\(else\|endif\)\>"
if !exists("c_no_if0")
  if !exists("c_no_if0_fold")
    syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2 fold
  else
    syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2
  endif
  syn region	cCppOut2	contained start="0" end="^\s*\(%:\|#\)\s*\(endif\>\|else\>\|elif\>\)" contains=cSpaceError,cCppSkip
  syn region	cCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cSpaceError,cCppSkip
endif
syn region	cIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	cIncluded	display contained "<[^>]*>"
syn match	cInclude	display "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
"syn match cLineSkip	"\\$"
syn cluster	cPreProcGroup	contains=cPreCondit,cIncluded,cInclude,cDefine,cErrInParen,cErrInBracket,cUserLabel,cSpecial,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cString,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cParen,cBracket,cMulti
syn region	cDefine		start="^\s*\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell
syn region	cPreProc	start="^\s*\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell

" Highlight User Labels
syn cluster	cMultiGroup	contains=cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cCppParen,cCppBracket,cCppString
syn region	cMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@cMultiGroup,@Spell
" Avoid matching foo::bar() in C++ by requiring that the next char is not ':'
syn cluster	cLabelGroup	contains=cUserLabel
syn match	cUserCont	display "^\s*\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display ";\s*\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display "^\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
syn match	cUserCont	display ";\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup

syn match	cUserLabel	display "\I\i*" contained

" Avoid recognizing most bitfields as labels
syn match	cBitField	display "^\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType
syn match	cBitField	display ";\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment cComment minlines=" . b:c_minlines
endif

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link cFormat		cSpecial
hi def link cCppString		cString
hi def link cCommentL		cComment
hi def link cCommentStart	cComment
hi def link cLabel		Label
hi def link cUserLabel		Label
hi def link cConditional	Conditional
hi def link cRepeat		Repeat
hi def link cCharacter		Character
hi def link cSpecialCharacter	cSpecial
hi def link cNumber		Number
hi def link cOctal		Number
hi def link cOctalZero		PreProc	 " link this to Error if you want
hi def link cFloat		Float
hi def link cOctalError		cError
hi def link cParenError		cError
hi def link cErrInParen		cError
hi def link cErrInBracket	cError
hi def link cCommentError	cError
hi def link cCommentStartError	cError
hi def link cSpaceError		cError
hi def link cSpecialError	cError
hi def link cCurlyError		cError
hi def link cOperator		Operator
hi def link cStructure		Structure
hi def link cStorageClass	StorageClass
hi def link cInclude		Include
hi def link cPreProc		PreProc
hi def link cDefine		Macro
hi def link cIncluded		cString
hi def link cError		Error
hi def link cStatement		Statement
hi def link cPreCondit		PreCondit
hi def link cType		Type
hi def link cConstant		Constant
hi def link cCommentString	cString
hi def link cComment2String	cString
hi def link cCommentSkip	cComment
hi def link cString		String
hi def link cComment		Comment
hi def link cSpecial		SpecialChar
hi def link cTodo		Todo
hi def link cBadContinuation	Error
hi def link cCppSkip		cCppOut
hi def link cCppOut2		cCppOut
hi def link cCppOut		Comment

hi def link cFunction   	Function
hi def link cForward    	Function

let b:current_syntax = "pawn"

let &cpo = s:cpo_save
unlet s:cpo_save
