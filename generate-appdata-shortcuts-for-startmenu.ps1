# Filename:    generate-appdata-shortcuts-for-startmenu.ps1
# Description: Generates executable shortcuts from AppData\Local for the running User's StartMenu.
# Author(s):   Alex Portell <github.com/portellam>
#

$username = $Env:UserName
Write-Host "Creating StartMenu shortcuts of AppData for $username..."
$appdata_path = "C:\Users\$username\AppData"
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
  exit
}

$startmenu_path = "$appdata_path\Roaming\Microsoft\Windows\Start Menu"
$shell = New-Object -ComObject WScript.Shell

foreach($file in $local_path_results)
{
  try
  {
    $file_last_folder = (Get-Item $file).Directory.Name
    $shortcut_dir = $startmenu_path + "\" + $file_last_folder
    $shortcut_path = $shortcut_dir + "\" + $file.BaseName + ".lnk"

    $shortcut = $shell.CreateShortCut($shortcut_path)
    $shortcut.TargetPath = $file.FullName

    New-Item -ItemType Directory -Path $shortcut_dir *>$null
    $shortcut.Save()
  }
  catch
  {
    Write-Host "An error occured:"
    Write-Host $_.ScriptStackTrace
  }
}

Write-Host "Done."
exit