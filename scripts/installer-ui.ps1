$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem
[Windows.Forms.Application]::EnableVisualStyles()
$bg=[Drawing.Color]::FromArgb(19,18,24);$panel=[Drawing.Color]::FromArgb(29,27,36);$accent=[Drawing.Color]::FromArgb(167,139,250);$text=[Drawing.Color]::FromArgb(244,241,250);$muted=[Drawing.Color]::FromArgb(163,158,174)
$form=New-Object Windows.Forms.Form;$form.Text='Playdeck Setup';$form.Size=New-Object Drawing.Size(610,390);$form.FormBorderStyle='FixedDialog';$form.MaximizeBox=$false;$form.MinimizeBox=$false;$form.StartPosition='CenterScreen';$form.BackColor=$bg;$form.ForeColor=$text
$heading=New-Object Windows.Forms.Label;$heading.Text='✦  PLAYDECK';$heading.Location=New-Object Drawing.Point(28,24);$heading.Size=New-Object Drawing.Size(180,24);$heading.ForeColor=$accent;$heading.Font=New-Object Drawing.Font('Segoe UI Semibold',10);$form.Controls.Add($heading)
$title=New-Object Windows.Forms.Label;$title.Text='Your next favourite thing.';$title.Location=New-Object Drawing.Point(28,58);$title.Size=New-Object Drawing.Size(540,38);$title.Font=New-Object Drawing.Font('Segoe UI Semibold',21);$form.Controls.Add($title)
$copy=New-Object Windows.Forms.Label;$copy.Text='One beautiful home for games, videos, music and more.';$copy.Location=New-Object Drawing.Point(31,102);$copy.Size=New-Object Drawing.Size(500,25);$copy.ForeColor=$muted;$form.Controls.Add($copy)
$label=New-Object Windows.Forms.Label;$label.Text='INSTALL LOCATION';$label.Location=New-Object Drawing.Point(31,157);$label.Size=New-Object Drawing.Size(200,20);$label.ForeColor=$accent;$label.Font=New-Object Drawing.Font('Consolas',8);$form.Controls.Add($label)
$folder=New-Object Windows.Forms.TextBox;$folder.Text=Join-Path $env:LOCALAPPDATA 'Programs\Playdeck';$folder.Location=New-Object Drawing.Point(31,182);$folder.Size=New-Object Drawing.Size(420,30);$folder.BackColor=$panel;$folder.ForeColor=$text;$folder.BorderStyle='FixedSingle';$form.Controls.Add($folder)
$browse=New-Object Windows.Forms.Button;$browse.Text='Browse';$browse.Location=New-Object Drawing.Point(462,181);$browse.Size=New-Object Drawing.Size(105,32);$browse.FlatStyle='Flat';$browse.BackColor=$panel;$browse.ForeColor=$text;$form.Controls.Add($browse)
$browse.Add_Click({$d=New-Object Windows.Forms.FolderBrowserDialog;$d.Description='Choose where Playdeck should be installed.';$d.ShowNewFolderButton=$true;if($d.ShowDialog($form)-eq[Windows.Forms.DialogResult]::OK){$folder.Text=Join-Path $d.SelectedPath 'Playdeck'}})
$desktop=New-Object Windows.Forms.CheckBox;$desktop.Text='Create a desktop shortcut';$desktop.Checked=$true;$desktop.Location=New-Object Drawing.Point(31,229);$desktop.Size=New-Object Drawing.Size(240,25);$desktop.ForeColor=$muted;$form.Controls.Add($desktop)
$info=New-Object Windows.Forms.Label;$info.Text='Your library and profile stay on this PC. Original files are never moved or deleted.';$info.Location=New-Object Drawing.Point(31,265);$info.Size=New-Object Drawing.Size(530,28);$info.ForeColor=$muted;$form.Controls.Add($info)
$status=New-Object Windows.Forms.Label;$status.Location=New-Object Drawing.Point(31,306);$status.Size=New-Object Drawing.Size(530,24);$status.ForeColor=$accent;$form.Controls.Add($status)
$install=New-Object Windows.Forms.Button;$install.Text='Install Playdeck  →';$install.Location=New-Object Drawing.Point(390,333);$install.Size=New-Object Drawing.Size(177,36);$install.FlatStyle='Flat';$install.FlatAppearance.BorderSize=0;$install.BackColor=$accent;$install.ForeColor=[Drawing.Color]::FromArgb(25,20,34);$install.Font=New-Object Drawing.Font('Segoe UI Semibold',10);$form.Controls.Add($install)
$cancel=New-Object Windows.Forms.Button;$cancel.Text='Cancel';$cancel.Location=New-Object Drawing.Point(302,333);$cancel.Size=New-Object Drawing.Size(78,36);$cancel.FlatStyle='Flat';$cancel.FlatAppearance.BorderSize=0;$cancel.BackColor=$bg;$cancel.ForeColor=$muted;$cancel.Add_Click({$form.Close()});$form.Controls.Add($cancel)
$install.Add_Click({
 try{
  $target=[Environment]::ExpandEnvironmentVariables($folder.Text.Trim());if([string]::IsNullOrWhiteSpace($target)){throw 'Choose an install folder first.'}
  if(Get-Process -Name Playdeck -ErrorAction SilentlyContinue){throw 'Please close Playdeck before installing or updating it.'}
  $install.Enabled=$false;$browse.Enabled=$false;$cancel.Enabled=$false;$folder.Enabled=$false;$status.Text='Setting up your space…';$form.Refresh()
  if(Test-Path $target){$children=@(Get-ChildItem -LiteralPath $target -Force);if($children.Count -gt 0 -and -not(Test-Path (Join-Path $target '.playdeck-install'))){throw 'Choose an empty folder or an existing Playdeck install folder.'}}
  New-Item -ItemType Directory -Force -Path $target|Out-Null
  [IO.Compression.ZipFile]::ExtractToDirectory((Join-Path $PSScriptRoot 'payload.zip'),$target,$true)
  $appExe=Join-Path $target 'Playdeck.exe';if(-not(Test-Path $appExe)){throw 'The app files could not be unpacked. Please try Setup again.'};Set-Content -LiteralPath (Join-Path $target '.playdeck-install') -Value '1.0.0' -Encoding ASCII
  $programs=[Environment]::GetFolderPath('Programs');$menu=Join-Path $programs 'Playdeck';New-Item -ItemType Directory -Force -Path $menu|Out-Null
  $ws=New-Object -ComObject WScript.Shell;$link=$ws.CreateShortcut((Join-Path $menu 'Playdeck.lnk'));$link.TargetPath=$appExe;$link.WorkingDirectory=$target;$link.IconLocation=$appExe+',0';$link.Save()
  if($desktop.Checked){$link=$ws.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Playdeck.lnk'));$link.TargetPath=$appExe;$link.WorkingDirectory=$target;$link.IconLocation=$appExe+',0';$link.Save()}
  $uninstaller=Join-Path $target 'uninstall.ps1'
  $uninstallText=@('$ErrorActionPreference = ''SilentlyContinue''','$root = $PSScriptRoot','Remove-Item -LiteralPath (Join-Path ([Environment]::GetFolderPath(''Programs'')) ''Playdeck'') -Recurse -Force','Remove-Item -LiteralPath (Join-Path ([Environment]::GetFolderPath(''Desktop'')) ''Playdeck.lnk'') -Force','Remove-Item -LiteralPath ''HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Playdeck'' -Recurse -Force','Start-Sleep -Seconds 2','if (Test-Path (Join-Path $root ''.playdeck-install'')) { Remove-Item -LiteralPath $root -Recurse -Force }')
  Set-Content -LiteralPath $uninstaller -Value ($uninstallText -join [Environment]::NewLine) -Encoding UTF8
  $key='HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Playdeck';New-Item -Path $key -Force|Out-Null;New-ItemProperty -Path $key -Name DisplayName -Value 'Playdeck' -PropertyType String -Force|Out-Null;New-ItemProperty -Path $key -Name DisplayVersion -Value '1.0.0' -PropertyType String -Force|Out-Null
  $uninstallCommand='powershell.exe -NoProfile -ExecutionPolicy Bypass -File "'+$uninstaller+'"';New-ItemProperty -Path $key -Name UninstallString -Value $uninstallCommand -PropertyType String -Force|Out-Null
  $status.Text='Installed! Your library is ready when you are.';$form.Refresh();Start-Sleep -Milliseconds 600
  $choice=[Windows.Forms.MessageBox]::Show('Playdeck is ready. Open it now?','Playdeck Setup','YesNo','Information');if($choice-eq[Windows.Forms.DialogResult]::Yes){Start-Process -FilePath $appExe -WorkingDirectory $target};$form.Close()
 }catch{$install.Enabled=$true;$browse.Enabled=$true;$cancel.Enabled=$true;$folder.Enabled=$true;[Windows.Forms.MessageBox]::Show($_.Exception.Message,'Playdeck Setup','OK','Error')|Out-Null}
})
[void]$form.ShowDialog()
