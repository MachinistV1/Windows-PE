$pathsWithExecutables = Get-CIMInstance -ClassName Win32_Service | Where-Object {($_.State -eq 'Running' -or $_.State -eq 'Stopped') -and ($_.PathName -match '\\[^\\]*\.exe')} | ForEach-Object { $_.PathName }

# Print each item in the array with quotes
# This part is kinda annoying since powershell doesn't have awk grep and sed...
foreach ($path in $pathsWithExecutables) {
    # This code can be improved.
    $string = $path
    $result = $string -replace "(?<=\.exe).*", '"'
    # Until hear all clean, let's remove "
    $result = $result.Replace("`"","").ToLower()
    #Write-Output $result
    # Write to a file...
    $result = $result.Insert(0, '"')
    $result = $result -replace "(?<=\.exe).*", '"'
    $result | Out-File hi.txt -Append
}
# This should work
Get-Content .\hi.txt | Sort-Object -Unique | Set-Content outme.txt

$inputFile = '.\outme.txt'

# Array with permissions outputs
$permissionOutputs = @()

# Iterate
foreach ($line in Get-Content $inputFile) {
    # Remove the "
    $path = $line.Trim('"')

    # Use icacls
    $icaclsOutput = & icacls "$path" | Out-String

    # Add output to array
    $permissionOutputs += $icaclsOutput
}

# Output to file
$permissionOutputs | Set-Content 'file'

Get-Content .\file

# Remove all the created files.
Remove-Item hi.txt, outme.txt, file
"------------------ Checking Spaces in Paths ------------------"
cmd.exe /c 'wmic service get name,pathname |  findstr /i /v "C:\Windows\\" | findstr /i /v """'
