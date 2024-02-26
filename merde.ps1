$excludes = (Get-Content .\exclude.txt | ForEach-Object {
    [regex]::Escape($_.replace("/", [IO.Path]::DirectorySeparatorChar).Trim())
}) -join "|"

# $excludes = @("C:\Windows\*", "C:\ProgramData\*", "C:\Program Files\*", "C:\Program Files (x86)\*", "C:\Users\clever\AppData\*")


# $excludes = @("C:\Program Files (x86)", "C:\Windows", "C:\ProgramData", "C:\Program Files", "C:\Users\clever\AppData")
# $excludes
# $excludes = [regex]::Escape("C:\Windows")
# $excludes
Get-ChildItem -Recurse -Path "C:\"  | Where-Object {
    $_.FullName -notmatch $excludes
} | ForEach-Object {
    Write-Host $_.FullName
}