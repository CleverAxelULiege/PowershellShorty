Clear-Host
# $string = "C:\Users\{{user}}\blablablabla"
# [regex]$pattern = "C:\\Users\\{{user}}"

# $pattern.replace($string, "test", 1) 
# 'C:\Users\{{user}}\blablablabla' -replace '(C:\\Users\\){{user}}(.*)', '$1baby$2'

# exit;

$historics = Get-ChildItem -Path .\shorty_historic | Sort-Object -Property BaseName;
$formatDate = "+%Y%m%d_%H%M%S"
$outputFile = ".\shorty_historic\unshorty" + (Get-Date -Date (Get-Date) -UFormat $formatDate) + ".txt";
Out-File -FilePath $outputFile

foreach ($historic in $historics) {
    [System.Collections.ArrayList]$changedFiles = Get-Content -Path $historic.FullName
    
    $saveIndex = 0;
    $i = 0;
    $countSeparatorSave = 0;
    while ($changedFiles.Count -ne 0) {
        $saveIndex = 0;
        $countSeparatorSave = 0;
        for($i = 0; $i -lt $changedFiles.Count; $i++){
            # Write-Host $changedFiles[$i]
            # Write-Host ($changedFiles[$i])
            
            $countSeparator = ($changedFiles[$i].ToCharArray() | Where-Object {$_ -eq [IO.Path]::DirectorySeparatorChar} | Measure-Object).Count
            
            if($countSeparator -gt $countSeparatorSave){
                $countSeparatorSave = $countSeparator
                $saveIndex = $i
            }
            
        }
        $countSeparatorSave
        $changedFiles[$saveIndex] | Out-File -FilePath $outputFile -Append
        $changedFiles.RemoveAt($saveIndex)
    }
}

Get-Content -Path $outputFile | ForEach-Object {
    [string[]]$data = $_ | ConvertFrom-Json

    if(Test-Path -Path $data[1]){
        Rename-Item -Path $data[1] -NewName $data[0].Substring($data[0].LastIndexOf([IO.Path]::DirectorySeparatorChar)+1)
    }
}

Remove-Item -Path $outputFile