# Filename:    generate-defaultprofile-startmenu-shortcuts.ps1
# Description: Generates executable shortcuts within Start Menu for the Default User.
# Author(s):   Alex Portell <github.com/portellam>
#

function main()
{
  $default_username = "Default"
  $username = $Env:UserName
  $username_reference = '%username%'

  $appdata_path = "C:\Users\$default_username\AppData"
  $local_path = "$appdata_path\Local\*\*"
  $roaming_path = "$appdata_path\Roaming\*\*"

  Write-Host "Creating Start Menu shortcuts for the Default User..."

  if(Create-Shortcuts-From-Path($local_path) -ne 0)
  {
    Write-Host "Failure."
    exit 1
  }

  if(Create-Shortcuts-From-Path($roaming_path) -ne 0)
  {
    Write-Host "Failure."
    exit 1
  }

  Write-Host "Success."
  exit 0
}

function Create-Shortcuts-From-Path($path)
{
  $has_passed_once = $false
  $startmenu_path = "$appdata_path\Roaming\Microsoft\Windows\Start Menu"
  $path_results = New-Object System.Collections.ArrayList
  $shell = New-Object -ComObject WScript.Shell

  foreach($file in Get-ChildItem $path)
  {
    if(-not($file -like "*.exe"))
    {
      continue
    }

    $path_results.Add($file) *>$null
  }

  if($path_results.Count -lt 1)
  {
    return 0
  }

  foreach($file in $path_results)
  {
    try
    {
	  $file_base_dir = (Get-Item $file).Directory.Name
	  $shortcut_dir = "$startmenu_path\$file_base_dir"
	  $shortcut_path = "$shortcut_dir\" + $file.BaseName + ".lnk"

	  $default_username_temp = "\$default_username\"
	  $username_reference_temp = "\$username_reference\"
	  $shortcut_target = $file.FullName.Replace($default_username_temp, $username_reference_temp)

	  $shortcut = $shell.CreateShortCut($shortcut_path)
	  $shortcut.TargetPath = $shortcut_target

	  New-Item -ItemType Directory -Path $shortcut_dir *>$null
	  $shortcut.Save()
	  $has_passed_once = $true
    }
    catch
    {
	  Write-Host "An error occured:"
	  Write-Host $_.ScriptStackTrace
    }
  }

  if($has_passed_once -eq $false)
  {
    return 1
  }

  return 0
}

main
