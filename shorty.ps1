
# exit
$username = [Environment]::UserName
$failSafeMinLengthValue = 75
$possibleAnswersConfirmation = @("Y", "N")
function ScanDisk {
    Write-Host "You choose to scan a a whole disk." -ForegroundColor Blue
    $fileSystemSelected = ""
    $fileSystemsAvailables = Get-PSDrive -PSProvider FileSystem | Select-Object Name, Root
    [string[]]$fileSystemsName = $fileSystemsAvailables | ForEach-Object {
        $_.Name.ToUpper()
    }

    Get-PSDrive -PSProvider FileSystem
    Write-Host ""
    while ($fileSystemSelected -notin $fileSystemsName) {
        Write-Host "Which disk would you like to scan ? Please enter the name of the disk that you'd like to scan." -ForegroundColor Blue
        $fileSystemSelected = (Read-Host).ToUpper()
    }

    $fileSystemPath = $fileSystemsAvailables | ForEach-Object {
        if ($_.Name.ToUpper() -eq $fileSystemSelected) {
            $_.Root
        }
    }

    $excludes = (Get-Content .\exclude.txt | ForEach-Object {
        if($_.Trim() -ne "" -and $_[0] -ne "#"){
            [regex]::Escape($_.replace("{{user}}", $username).replace("/", [IO.Path]::DirectorySeparatorChar).Trim())
        }
        }) -join "|"

    Clear-Host
    Write-Host "We will use this path as the start of the scan : " -NoNewline -ForegroundColor Blue
    Write-Host '"'$fileSystemPath'"' -ForegroundColor Yellow
    Write-Host ""
    Write-Host "We will also exclude those pathes provided by the exclude.txt file :" -ForegroundColor Blue

    Get-Content .\exclude.txt | ForEach-Object {
        if($_.Trim() -ne "" -and $_[0] -ne "#"){
            Write-Host $_.replace("{{user}}", $username) -ForegroundColor Cyan
        }
    }

    Write-Host ""
    Write-Host "If you'd like to provide more pathes or chunk of pathes to ignore, stop the script with CTRL + C and edit the exclude.txt file." -ForegroundColor Blue
    Read-Host "Press enter to continue"


    Clear-Host
    $confirmLength = 0
    $maxLengthName = 0;
    while ($confirmLength -eq 0) {
        Write-Host "What max name length should we target (extension excluded) ? Please provide a positive integer :" -ForegroundColor Blue
        $maxLengthName = Read-Host

        if ($maxLengthName -match '^[0-9]+$') {

            if ([int32]$maxLengthName -lt $failSafeMinLengthValue) {
                Write-Host "The minimum length that you can give must be at least at $failSafeMinLengthValue, this is a fail safe. Edit the script to change this value." -ForegroundColor Red
            }
            else {
                $answerConfirmLength = ""
                while ($answerConfirmLength -notin $possibleAnswersConfirmation) {                
                    Write-Host "Should we target files/directories that exceed"$maxLengthName" character(s) (extension excluded) ?" -NoNewline -ForegroundColor Blue
                    Write-Host " (Y/N)" -ForegroundColor Yellow
                    $answerConfirmLength = (Read-Host).ToUpper()
                }
    
                if ($answerConfirmLength -eq "Y") {
                    $confirmLength = 1;
                }
            }
        }
    }

    $maxLengthName = [int32]$maxLengthName

    Get-ChildItem -Path $fileSystemPath | Where-Object {
        $_.FullName -notmatch $excludes
    } | ForEach-Object {
        if($_.PSIsContainer){
            Write-Host "Scanning" $_.FullName -ForegroundColor Green
            Get-ChildItem -Path $_.FullName -Recurse -ErrorAction SilentlyContinue | Where-Object {
                $_.FullName -notmatch $excludes
            } | ForEach-Object {
                if($_.BaseName.length -gt $maxLengthName){
                    $newName = [guid]::NewGuid().ToString()
                    $index = $_.FullName.LastIndexOf([IO.Path]::DirectorySeparatorChar)
                    $path = $_.FullName.Substring(0, $index+1)
                    
                    if(-not($_.PSIsContainer)){
                        $newName += $_.Extension
                    } 
                    @($_.FullName, ($path + $newName)) | ConvertTo-Json -Compress | Out-File -FilePath $outputFile -Append
                    Rename-Item -Path $_.FullName -NewName $newName
    
                    Write-Host "Changed " -NoNewline
                    Write-Host $_.FullName -ForegroundColor Yellow -NoNewline
                    Write-Host " to " -NoNewline
                    Write-Host ($path + $newName) -ForegroundColor Yellow
                }
            }
        } else {
            if($_.BaseName.length -gt $maxLengthName){
                $newName = [guid]::NewGuid().ToString()
                $index = $_.FullName.LastIndexOf([IO.Path]::DirectorySeparatorChar)
                $path = $_.FullName.Substring(0, $index+1)
                
                if(-not($_.PSIsContainer)){
                    $newName += $_.Extension
                } 
                @($_.FullName, ($path + $newName)) | ConvertTo-Json -Compress | Out-File -FilePath $outputFile -Append
                Rename-Item -Path $_.FullName -NewName $newName

                Write-Host "Changed " -NoNewline
                Write-Host $_.FullName -ForegroundColor Yellow -NoNewline
                Write-Host " to " -NoNewline
                Write-Host ($path + $newName) -ForegroundColor Yellow
            }
        }
    }
}

function ScanPath {
    Write-Host "You choose to scan a specific path"
}


Clear-Host
# [guid]::NewGuid().ToString()
# $formatDate = "+%Y%m%d_%H%M%S"
# $outputFile = (Get-Date -Date (Get-Date) -UFormat $formatDate) + ".txt";
# @("test", "truc") | ConvertTo-Json -Compress | Out-File -FilePath $outputFile
# exit;
if (-not(Test-Path -Path .\exclude.txt)) {
    Write-Host "No exclude.txt file found in the same directory as the shorty script please provide one, exiting script..." -ForegroundColor Red
    Read-Host "Press enter to continue"
    exit;
}

Write-Host "Welcome to Shorty" -ForegroundColor Blue
Write-Host "Remember that you can stop the script at any moment by pressing CTRL + C" -ForegroundColor Red
Write-Host ""
Write-Host ""

while (-not(Test-Path -Path ("C:\Users\" + $username))) {
    Write-Host "Failed to retrieve the name of the current session being in use." -ForegroundColor Red
    Write-Host "Please enter the correct name of the session : " -ForegroundColor Red
    $username = Read-Host
}

$answerScan = "";
$possibleAnswersScan = @("disk", "path", "d", "p")
while ($answerScan -notin $possibleAnswersScan) {
    Write-Host "Would you like to scan a whole disk or a specific path ? " -NoNewline -ForegroundColor Blue
    Write-Host "(disk/path)" -ForegroundColor Yellow
    $answerScan = (Read-Host).ToLower()
}

Clear-Host

$formatDate = "+%Y%m%d_%H%M%S"
$outputFile = ".\shorty_historic\" + (Get-Date -Date (Get-Date) -UFormat $formatDate) + ".txt";
Out-File -FilePath $outputFile

Write-Host "Created historic of modified files as"$outputFile -ForegroundColor Green

switch ($answerScan) {
    "disk" { ScanDisk }
    "d" { ScanDisk }
    "path" { ScanPath }
    "p" { ScanPath }
}

