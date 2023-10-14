# Filename:    generate-startmenu-shortcuts.ps1
# Description: Generates executable shortcuts within Start Menu for the Default User.
# Author(s):   Alex Portell <github.com/portellam>
#

$username = $Env:UserName
$default_username = "Default"
$default_username_reference = '%username%'

Write-Host "Creating StartMenu shortcuts..."

$appdata_path = "C:\Users\$default_username\AppData"
$local_path = "$appdata_path\Local\*\*"
$local_path_results = New-Object System.Collections.ArrayList

foreach($file in Get-ChildItem $local_path)
{
  if(-not($file -like "*.exe"))
  {
    continue
  }

  $local_path_results.Add($file) *>$null
}

if($local_path_results.Count -le 0)
{
  Write-Host "Skipped."
  exit 0
}

$startmenu_path = "$appdata_path\Roaming\Microsoft\Windows\Start Menu"
$shell = New-Object -ComObject WScript.Shell
$has_passed_once = $false

foreach($file in $local_path_results)
{
  try
  {
    $file_last_folder = (Get-Item $file).Directory.Name
    $shortcut_dir = $startmenu_path + "\" + $file_last_folder
    $shortcut_path = $shortcut_dir + "\" + $file.BaseName + ".lnk"

    $username_temp = "\" + $username + "\"
    $default_username_reference_temp = "\" + $default_username_reference + "\"
    $shortcut_target = $file.FullName.Replace($username_temp, $default_username_reference_temp)

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

if($has_passed_once -ne $true)
{
    Write-Host "Failed."
    exit 1
}

Write-Host "Success."
exit 0
