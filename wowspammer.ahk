#NoEnv                        ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input                ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%   ; Ensures a consistent starting directory.

WinGet, wowid, ID, World of Warcraft

F1::
if (enable := !enable)
  setTimer, MoveAround, -1
return

MoveAround:
while enable
{
  ifWinExist, ahk_id %wowid%
  {
   
   ControlSend,, {1}, ahk_id %wowid%


    Sleep 3000
  }
}
return