# [IO.Path]::DirectorySeparatorChar
Clear-Host
# $stuff = @("\node_modules\", "C:\Program Files (x86)", "test", "node_modulgtgre", "library.dll", "img.png")

$excludes = (Get-Content .\exclude.txt | ForEach-Object {
    # ($_ -replace "/", [IO.Path]::DirectorySeparatorChar).Trim() -replace '[[+*?()\\.]','\$&'
    [regex]::Escape(($_ -replace "/", [IO.Path]::DirectorySeparatorChar).Trim())
    # ($_ -replace "/", [IO.Path]::DirectorySeparatorChar).Trim() -replace '[[+*?()\\.]','\$&'
}) -join "|"

$(Get-CimInstance Win32_ComputerSystem | Select-Object username).username

# $excludes
# $excludes = "\node_modules\|Program Files" -replace "\\", "\\"
# $excludes
# $excludes = "node_modules"
# $excludes = "Program Files|node_modules"

# $mabite = $stuff | Where-Object { $_ -notmatch  $excludes}
# $mabite

# powershell -executionpolicy bypass -File .\shortirotronator.ps1

# Write-Host "Welcome to the shortirotronator script :D"
# Write-Host "This script has for goal to shorten the name of files or directories too long."
# Write-Host "Remember, if you'd like to stop the script at any time press CTRL + C " -ForegroundColor Red
# Write-Host "First and foremost, what file system do you want to analyze ? " -ForegroundColor Yellow
# Get-PSDrive -PSProvider FileSystem
# $fileSystemsAvailables = Get-PSDrive -PSProvider FileSystem | Select-Object Name, Root
# [string[]]$fileSystemsName = $fileSystemsAvailables | ForEach-Object {
#     $_.Name.ToUpper()
# }
# Write-Host ""
# $fileSystemSelected = "";

# while($fileSystemSelected -notin $fileSystemsName){
#     $fileSystemSelected = (Read-Host "Please type the character of the name of the file system that you'd like to use ").ToUpper()
#     if($fileSystemSelected -notin $fileSystemsName){
#         Write-Host "This file system doesn't exist." -ForegroundColor Red
#     }
# }

# $fileSystemPath = $fileSystemsAvailables | ForEach-Object {
#     if($_.Name.ToUpper() -eq $fileSystemSelected){
#         $_.Root
#     }
# }

# Clear-Host


# Get-ChildItem -Recurse | Where-Object {
#     $_.FullName -notmatch $excludes
# } | ForEach-Object {

#     Write-Host $_.FullName
# }

# for ($i = 1; $i -le 100; $i++ )
# {
# Write-Progress -Activity "Search in Progress" -Status "$i% Complete:" -PercentComplete $i
# Start-Sleep -Milliseconds 250
# }