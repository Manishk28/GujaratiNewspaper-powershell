# Determine script location for PowerShell
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$targetDir = "$DesktopPath\Newspapers\"
$MSDir = "$DesktopPath\Newspapers\Mumbai_samachar\"

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

# set date
$date = Get-Date

# set date mumbai samachar
$datems1 = $date.ToString("dd-MM-yyyy")
$datems2 = $date.ToString("ddMMyy")

# Creating filename list for mumbai samachar.
$MSPaperlist = new-object -TypeName "System.Collections.ArrayList"

$WebResponse = Invoke-WebRequest "https://bombaysamachar.com/%E0%AA%87-%E0%AA%AA%E0%AB%87%E0%AA%AA%E0%AA%B0/"
$filteredHTML = ($WebResponse.ParsedHtml.body.getElementsbyClassName('_df_thumb '))
$pattern = 'thumb="(.*).jpg'
foreach ($element in $filteredHTML)
{
    If(([regex]::match($element.outerHTML, $pattern).Groups[1].Value) -match $datems2){
        $link = [regex]::match($element.outerHTML, $pattern).Groups[1].Value + ".pdf"
        $MSPaperlist.Add($link)
    }
}

DownloadFile $MSPaperlist $MSDir


#merge pdfs
Start-Process -FilePath "$ScriptDir\PDFtk\pdftk.exe" -ArgumentList "Mumbai_samachar\*.pdf cat output MumbaiSamachar.pdf" -WorkingDirectory $targetDir -wait

#delete each directory.
Remove-Item $MSDir -Recurse