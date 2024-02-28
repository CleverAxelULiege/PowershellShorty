
# Rename-Item -Path "D:\rename\subdir\bonjour.txt" -NewName "D:\rename\subdir\hello.txt" -WhatIf

# exit
$username = [Environment]::UserName
# $possibleAnswersConfirmation = @("Y", "N")
$maxLengthAbsolutePath = 256
$actionPath = ""
$pathRename = ""
$newName = ""
$prefixLitteralPath = "\\?\"

function DoesPathTooLongExist {
    param (
        [array] $pathes
    )

    foreach ($currentItemName in $pathes) {
        if ($currentItemName.Length -gt $maxLengthAbsolutePath) {
            return $true
        }
    }

    return $false
}

function GetReconstructedPath {
    param (
        [array] $treeStructure
    )
    # Write-Host $actionPath
    # $actionPath + ($treeStructure -join [IO.Path]::DirectorySeparatorChar)
    return ($actionPath + ($treeStructure -join [IO.Path]::DirectorySeparatorChar))
}

function RenameAbsolutePathTooLong {
    $excludes = (Get-Content .\exclude.txt | ForEach-Object {
            if ($_.Trim() -ne "" -and $_[0] -ne "#") {
                [regex]::Escape($_.replace("{{user}}", $username).replace("/", [IO.Path]::DirectorySeparatorChar).Trim())
            }
        }) -join "|"

    Clear-Host
    Write-Host "We will use this path as the start of the scan : " -NoNewline -ForegroundColor Blue
    Write-Host '"'$actionPath'"' -ForegroundColor Yellow
    Write-Host ""
    Write-Host "We will also exclude those pathes provided by the exclude.txt file :" -ForegroundColor Blue
    $actionPath = $prefixLitteralPath + $actionPath


    Get-Content .\exclude.txt | ForEach-Object {
        if ($_.Trim() -ne "" -and $_[0] -ne "#") {
            Write-Host $_.replace("{{user}}", $username) -ForegroundColor Cyan
        }
    }

    Write-Host ""
    Write-Host "If you'd like to provide more pathes or chunk of pathes to ignore, stop the script with CTRL + C and edit the exclude.txt file." -ForegroundColor Blue
    # Read-Host "Press enter to continue and start the scan to rename the absolute pathes too long "
    Clear-Host

    Get-ChildItem -LiteralPath $actionPath | Where-Object {
        $_.FullName -notmatch $excludes
    } | ForEach-Object {
        $absolutePathesTooLong = New-Object System.Collections.Generic.List[System.String]
        Get-ChildItem -LiteralPath $_.FullName -Recurse | Where-Object { $_.FullName.Length -gt $maxLengthAbsolutePath } | ForEach-Object {
            $absolutePathesTooLong.Add($_.FullName)
            # # if ($pathRename -ne "") {
            # #     Rename-Item -LiteralPath $pathRename -NewName $newName
            # #     $pathRename
            # #     $newName
            # #     $pathRename = ""
            # # }
            # $path = $_.FullName
            # $extension = "";
            # if (-not($_.PSIsContainer)) {
            #     $extension = $_.Extension
            # }

            # $treeStructure = ($path | Select-String -Pattern ("^" + [regex]::Escape($actionPath) + "(.*)")).Matches.Groups[1].Value -split "\\"
            # $newTreeStructure = $treeStructure.Clone()
            # $testTreeStructure = New-Object System.Collections.Generic.List[System.String]
            # # (GetReconstructedPath -treeStructure $treeStructure)
            # $i = 0;
            
            # while ($i -lt $treeStructure.Length -and (GetReconstructedPath -treeStructure $newTreeStructure).Length -gt $maxLengthAbsolutePath) {
            #     $newDirFileName = 0;
            #     $testTreeStructure.Add($newDirFileName.ToString())

            #     if ($i -eq $treeStructure.Length - 1) {
            #         $testTreeStructure[$i] = $testTreeStructure[$i] + $extension
            #     }

            #     while (Test-Path -LiteralPath (GetReconstructedPath -treeStructure $testTreeStructure)) {
            #         $newDirFileName++;
            #         if ($i -eq $treeStructure.Length - 1) {
            #             $testTreeStructure[$i] = $testTreeStructure[$i] + $extension
            #         }
            #         else {
            #             $testTreeStructure[$i] = $newDirFileName.ToString()
            #         }
            #     }



            #     $pathRename = (GetReconstructedPath -treeStructure ($newTreeStructure[0..($testTreeStructure.Count - 1)]))
            #     $newName = $testTreeStructure[$i]
            #     $newTreeStructure[$i] = $testTreeStructure[$i]

            #     # (GetReconstructedPath -treeStructure $newTreeStructure)
            #     # Rename-Item -LiteralPath $pathRename -NewName $newName

            #     # @($pathRename, ($pathRename.Substring(0, $pathRename.LastIndexOf([IO.Path]::DirectorySeparatorChar) + 1) + $newName)) | ConvertTo-Json -Compress | Out-File -FilePath $outputFile -Append
            #     $i++;
            # }

            
        }

        $copyPathes = $absolutePathesTooLong.ToArray()
        # $copyPath[0] = "test"
        # DoesPathTooLongExist -pathes $copyPathes
        # while(DoesPathTooLongExist -pathes $copyPathes){

        # }
        $newDirFileName = 0;
        foreach ($path in $copyPathes) {
            # $path
            $item = Get-Item -LiteralPath $path
            
            $extension = "";
            if (-not($item.PSIsContainer)) {
                $extension = $item.Extension
                # $item
            }



            
            $treeStructure = ($path | Select-String -Pattern ("^" + [regex]::Escape($actionPath) + "(.*)")).Matches.Groups[1].Value -split "\\"
            $newTreeStructure = $treeStructure.Clone()
            $testTreeStructure = New-Object System.Collections.Generic.List[System.String]
            $index = 0;
            while ($index -lt $treeStructure.Length -and (GetReconstructedPath -treeStructure $newTreeStructure).Length -gt $maxLengthAbsolutePath) {
                if($treeStructure[$index] -match ("^[\d\.]+(" + [regex]::Escape($extension) + ")?$")){
                    $testTreeStructure.Add($treeStructure[$index])
                    $newDirFileName++;
                    $index++
                    continue
                }
                # Write-Host "in"
                
                $testTreeStructure.Add($newDirFileName.ToString())
                while ($testTreeStructure[$index] -eq $item.BaseName) {
                    $newDirFileName++;
                    $testTreeStructure[$index] = $newDirFileName.ToString()
                }
                
                if ($index -eq $treeStructure.Length - 1) {
                    $testTreeStructure[$index] = $testTreeStructure[$index] + $extension
                }
                
                $newTreeStructure[$index] = $testTreeStructure[$index]
                # $newTreeStructure
                $replace = (GetReconstructedPath -treeStructure ($treeStructure[0..$index]))
                $replacement = (GetReconstructedPath -treeStructure $testTreeStructure)
                
                $copyPathes
                for ($i = 0; $i -lt $copyPathes.Length; $i++) {
                    $copyPathes[$i] = $copyPathes[$i] -replace ("^" + [regex]::Escape($replace)), $replacement
                }
                Write-Host "-------------------------" -ForegroundColor Green
                $copyPathes
                $newDirFileName++;
                $index++
                # $newDirFileName
                # $replace
                # $replacement
            }
            Write-Host "------------"
            
            # break
        }
        
        Write-Host "------------" -ForegroundColor Red
        # $copyPathes
        # Write-Host "Rename complete."
    }
}

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

    $actionPath = $fileSystemsAvailables | ForEach-Object {
        if ($_.Name.ToUpper() -eq $fileSystemSelected) {
            $_.Root
        }
    }
    $null = $actionPath

    RenameAbsolutePathTooLong
}

function ScanPath {
    Write-Host ""
    Write-Host "You choose to scan a specific path" -ForegroundColor Blue
    $actionPath = "unknown"
    $actionPath = "D:\longgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"
    while (-not(Test-Path -Path $actionPath)) {
        Write-Host "Please enter an absolute path to start from :" -ForegroundColor Blue
        $actionPath = Read-Host

        if ($actionPath.Trim() -eq "") {
            $actionPath = "unknown"
        }
    }

    if ($actionPath[$actionPath.Length - 1] -ne [IO.Path]::DirectorySeparatorChar) {
        $actionPath += [IO.Path]::DirectorySeparatorChar
    }

    RenameAbsolutePathTooLong
}


Clear-Host
if (-not(Test-Path -Path .\exclude.txt)) {
    Write-Host "No exclude.txt file found in the same directory as the shorty script please provide one, exiting script..." -ForegroundColor Red
    Read-Host "Press enter to continue"
    exit;
}
ScanPath
exit;


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
if (-not(Test-Path -Path .\shortystoric)) {
    $null = New-Item -Path ".\shortystoric" -ItemType Directory
    Write-Host "Created shortystoric directory" -ForegroundColor Blue
}

$formatDate = "+%Y%m%d%H%M%S"
$outputFile = ".\shortystoric\" + (Get-Date -Date (Get-Date) -UFormat $formatDate) + ".txt";
# Out-File -FilePath $outputFile
Write-Host "Created shortystoric file as"$outputFile -ForegroundColor Blue

switch ($answerScan) {
    "disk" { ScanDisk }
    "d" { ScanDisk }
    "path" { ScanPath }
    "p" { ScanPath }
}

