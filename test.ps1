#powershell -executionpolicy bypass -File .\test.ps1
# $directories = Get-ChildItem  -Recurse
# Clear-Host
# foreach ($directory in $directories) {
#     $item = Get-Item -Path $directory.FullName
#     if($item.Name -eq "folder"){
#         Rename-Item -Path $item.FullName -NewName "new_folder"
#     } else {
#         Write-Host $item.FullName
#     }
# }
Clear-Host


# $string = "hello world";
# for ($i = 0; $i -lt $string.Length; $i++) {
#     Write-Host $string[$i]
# }

# [string[]]$array = @("hello", "world")
# $array | ConvertTo-Json -Compress

# Write-Host "hello" -ForegroundColor Green


# Get-ChildItem -Recurse | ForEach-Object {
#     if($_.Name -eq "folder"){
#         Rename-Item -Path $_ -NewName "new_folder"
#     } else {
#         Write-Host $_.FullName
#     }
#     # Write-Host $_.FullName
# }