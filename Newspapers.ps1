# Determine script location for PowerShell
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$targetDir = "$DesktopPath\Newspapers\"
$MSDir = "$DesktopPath\Newspapers\Mumbai_samachar\"
$GSDir = "$DesktopPath\Newspapers\Gujarat_samachar\"

# Download function.
function DownloadFile([Object[]] $sourceFiles,[string]$targetDirectory) {            
 $wc = New-Object System.Net.WebClient            
    $i=0         
 foreach ($sourceFile in $sourceFiles){            
  $sourceFileName = $sourceFile.SubString($sourceFile.LastIndexOf('/')+1)            
  $targetFileName = $targetDirectory + "Newpaper_page" + $i.ToString('00') + ".pdf"       
  $wc.DownloadFile($sourceFile, $targetFileName)            
  Write-Host "Downloaded $sourceFile to file location $targetFileName"
  $i++          
 }            
            
}

# create folders if not exists
if (!(test-path -path $MSDir)) {new-item -path $MSDir -itemtype directory}
if (!(test-path -path $GSDir)) {new-item -path $GSDir -itemtype directory}

# set date
$date = Get-Date

# set date mumbai samachar
$datems1 = $date.ToString("dd-MM-yyyy")
$datems2 = $date.ToString("ddMMyy")

# set date gujaratsamachar
$dategs1 = $date.ToString("yyyy/MM/dd")
$dategs2 = $date.ToString("yyyyMMdd")


# Creating filename list for mumbai samachar.
$MSPaperlist = new-object -TypeName "System.Collections.ArrayList"
for ($i = 1; $i -lt 20; $i++) {
#http://bombaysamachar.com/epaper/e31-10-2020/MS_311020_MSMU_01.pdf
  $MSPaperlist.add("http://bombaysamachar.com/epaper/e" +$datems1+ "/MS_" +$datems2+ "_MSMU_" + $i.ToString('00') + ".pdf")
}

# Creating filename list for gujarat samachar.
$GSPaperlist = new-object -TypeName "System.Collections.ArrayList"
for ($i = 1; $i -lt 20; $i++) {
#http://epapergujaratsamachar.com/download.php?file=http://enewspapr.com/News/GUJARAT/MUM/2020/10/31/20201031_1.PDF
  $GSPaperlist.add("http://epapergujaratsamachar.com/download.php?file=http://enewspapr.com/News/GUJARAT/MUM/" +$dategs1+ "/" +$dategs2+"_$i.PDF")
}
      
DownloadFile $GSPaperlist $GSDir            
DownloadFile $MSPaperlist $MSDir

#Delete Files of 0kb
Get-ChildItem -Path $GSDir -Recurse -Force | Where-Object { $_.PSIsContainer -eq $false -and $_.Length -eq 0 }  | remove-item

#merge pdfs
#Start-Process -FilePath "C:\Program Files (x86)\PDFtk\bin\pdftk.exe" -ArgumentList "Gujarat_samachar\*.pdf cat output GujaratSamachar.pdf" -WorkingDirectory $targetDir -wait
#Start-Process -FilePath "C:\Program Files (x86)\PDFtk\bin\pdftk.exe" -ArgumentList "Mumbai_samachar\*.pdf cat output MumbaiSamachar.pdf" -WorkingDirectory $targetDir -wait
Start-Process -FilePath "$ScriptDir\PDFtk\pdftk.exe" -ArgumentList "Gujarat_samachar\*.pdf cat output GujaratSamachar.pdf" -WorkingDirectory $targetDir -wait
Start-Process -FilePath "$ScriptDir\PDFtk\pdftk.exe" -ArgumentList "Mumbai_samachar\*.pdf cat output MumbaiSamachar.pdf" -WorkingDirectory $targetDir -wait

#delete each directory.
Remove-Item $GSDir -Recurse
Remove-Item $MSDir -Recurse