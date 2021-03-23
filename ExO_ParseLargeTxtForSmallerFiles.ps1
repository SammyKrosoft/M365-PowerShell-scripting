#This is a hack but works.
 
param
(
    $BigFile = (Read-Host "Enter file to parse into 100").Trim('"')
)
 
$BigFile
$listsize=80
 
$bigfilelist=Get-Content $bigfile -ErrorAction Stop
$bigfilelist.count
 
Write-host " "
Write-host "About to parse:  $bigfile of "+$bigfile.count+" items " -ForeGroundColor Green
Write-host " "
 
Read-Host "Hit ENTER to continue or Ctrl+C to quit"
 
$log = ".\bigtolittle.log"
Get-Date | Out-File $Log 
$i=1
$j=1
$fileindex=1
$outputfile=$bigfile+$fileindex+".txt"
$bigfilelist | Foreach {
    $i++
    $j++
    if( $j -eq $listsize ) { 
        $j=1 
        $fileindex++
        $outputfile=$bigfile+$fileindex+".txt"
    }
    $outputitem=$bigfilelist[$i]
    $writeitem=$outputitem
    $k=$i-1
    "Working on "+ $k+ " of "+ $Bigfilelist.count + " Writing " +$writeitem+" To File: "+$outputfile
    $writeitem>>$outputfile
} 
