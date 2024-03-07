/**
 * @description Checks the current THQBY AHK2 Extension and ensures that GroggyOtter's Version of the AHK definition file and ahk2.json files are installed.
 * @param {String} Installation_Path - This is the path to the Syntaxes folder in the extension
 * @param {String} ExtensionsFolder - This is the path of the user's extensions folder in VS Code
 * @param {Array} replacing[] - [1] & [2] hold boolean values of whether each file will be replaced. [3] is bool of whether the originals have already been backed up
 * continued: [1] & [2] become strings with the name of the file if that file was replaced. [3] becomes a string equal to " and " if both files were replaced.
 * @param {File} iniPath is the path of the settings file
 * @param {File} Def_File is the path to GroggyOtter's ahk2.d.ahk file
 * @param {File} Json_File is the path to GroggyOtter's ahk2.json file
 * @param {Number} D_FileSize is the file size of GroggyOtter's ahk2.d.ahk file
 * @param {Number} J_FileSize is the file size of GroggyOtter's ahk2.json file
 * @author Laser-Made aka Laser1092
 * @date 03/07/2024
 * @version 1.1
 */
#Requires AutoHotkey v2.0
#SingleInstance Force

iniPath := ""
Def_File := "", Json_File := ""
D_FileSize := 0, J_FileSize := 0
replacing := [false, false]
Installation_Path := ""
ExtensionsFolder := ""

if IniRead(A_ScriptDir "\pref\Settings.ini", "Start", "FirstRun") = true{
    iniPath := A_ScriptDir "\pref\Settings.ini"
    loop files "*", "F"
        {
            if A_LoopFileName = "ahk2.d.ahk"{
                Def_File := A_LoopFileFullPath
                D_FileSize := A_LoopFileSize
            }
            if A_LoopFileName = "ahk2.json" {
                Json_File := A_LoopFileFullPath
                J_FileSize := A_LoopFileSize
            }
        }
    IniWrite(Def_File, iniPath, "Folders", "D_File")
    IniWrite(Json_File, iniPath, "Folders", "J_File")
    IniWrite(iniPath, iniPath, "Folders", "iniFile")
    IniWrite(false, iniPath, "Start", "FirstRun")
}
else{
    Def_File := iniRead(iniPath, "Folders", "D_File", A_ScriptDir "ahk2.d.ahk")
    Json_File := iniRead(iniPath, "Folders", "J_File", A_ScriptDir "ahk2.json")
    D_FileSize := FileGetSize(Def_File)
    J_FileSize := FileGetSize(Json_File)
}

DriveLetter := StrSplit(A_ProgramFiles, ":", 1)[1]
loop files DriveLetter ":\*" , "DR" {
    if StrReplace(A_LoopFileName, A_Space) ~= "i)VSCODE"
        if DirExist(A_LoopFileFullPath "\extensions\thqby*")~="D"{
            ExtensionsFolder := A_LoopFileFullPath "\extensions"
            break
        }   
}
if ExtensionsFolder = ""
    ExtensionsFolder := UserSelect()
loop files ExtensionsFolder "\thqby*", "DR"{
    if A_LoopFileName ~= "i)thqby"
        Installation_Path := A_LoopFileFullPath "\syntaxes"
}
if DirExist(ExtensionsFolder "thqby*")~="D"
    loop files ExtensionsFolder "*", "DR"{
        if A_LoopFilePath ~= "thqby*"{
            MsgBox(A_LoopFileFullPath)
            Installation_Path := A_LoopFileFullPath "\syntaxes"
            break
        }
    }

if !DirExist(Installation_Path "\THQBY"){
    DirCreate(Installation_Path "\THQBY")
    replacing.Push(false)   ;adding 3rd boolean to track if this program has already moved these files before
}
else 
    replacing.push(true)   ;if the Dir did exist then [3] is true
loop files Installation_Path "\*.*", "F"
    {
        
        if A_LoopFileName = "ahk2.d.ahk" || A_LoopFileName = "ahk2.json" {
            if A_LoopFileSize != D_FileSize && A_LoopFileName = "ahk2.d.ahk" {
                replacing[1] := true
                replacing[3] ? FileMove(Installation_Path "\ahk2.d.ahk", Installation_Path "\THQBY\ahk2.d.ahk") : FileDelete(Installation_Path "\ahk2.d.ahk")
                FileCopy(Def_File, Installation_Path)
            }   
            if A_LoopFileSize != J_FileSize && A_LoopFileName = "ahk2.json" {
                replacing[2] := true                    
                replacing[3] ? FileMove(Installation_Path "\ahk2.json", Installation_Path "\THQBY\ahk2.json") : FileDelete(Installation_Path "\ahk2.json")
                FileCopy(Json_File, Installation_Path)
            }   
        }
    }
if replacing[1] || replacing[2] {
    replacing[1] ? (replacing[1] := "ahk2.d.ahk") : (replacing[1]:= "")
    replacing[2] ? (replacing[2] := "ahk2.json") : (replacing[2]:= "")
    replacing[1] && replacing[2] ? (replacing[3]:= " and ") : (replacing[3]:= "")
    MsgBox("The current THQBY extension does not use GroggyOtter's add-on"
    . "`n" . "The current THQBY files have been moved to the THQBY folder and have been replaced with GroggyOtter's add-on"
    . "`n" . "Copied " replacing[1] . replacing[3] . replacing[2] " to: " Installation_Path)
}

UserSelect(){
    UserFolder := IniRead("Settings.ini", "Folders", "Extensions", "not set")
    if UserFolder = "not set"{
        UserFolder := DirSelect(A_ProgramFiles, 3, 'Select the folder named "extensions" in your VSCode installation`n'
        . 'Example: C:\Program Files\VSCode\extensions')
        IniWrite(UserFolder, "Settings.ini", "Folders", "Extensions")
    }
    return UserFolder
}

Esc::ExitApp()

ExitApp()