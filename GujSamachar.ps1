# Determine script location for PowerShell
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$targetDir = "$DesktopPath\Newspapers\"
$GSDir = "$DesktopPath\Newspapers\Gujarat_samachar\"

# Download function.
function DownloadFile([Object[]] $sourceFiles,[string]$targetDirectory) {            
 $wc = New-Object System.Net.WebClient            
    $i=0         
 foreach ($sourceFile in $sourceFiles){            
  $sourceFileName = $sourceFile.SubString($sourceFile.LastIndexOf('/')+1)            
  $targetFileName = $targetDirectory + "Newpaper_page" + $i.ToString('00') + ".jpg"       
  $wc.DownloadFile($sourceFile, $targetFileName)       
  Write-Host "Downloaded $sourceFile to file location $targetFileName"
  $i++          
 }            
            
}

# create folder if not exists
if (!(test-path -path $GSDir)) {new-item -path $GSDir -itemtype directory}


# Creating filename list for gujarat samachar.
$GSPaperlist = new-object -TypeName "System.Collections.ArrayList"

$WebResponse = Invoke-WebRequest "https://epaper.gujaratsamachar.com/mumbai/06-08-2022/1"
$srcrpattern = '(?i)src="(.*?)"'

$src = ([regex]$srcrpattern).Matches($WebResponse.RawContent) | ForEach-Object { $_.Groups[1].Value }

ForEach($value in $src){
    If($value -match "https://epaperstatic.gujaratsamachar.com/epaper/thumbnail/"){ 
        $link = $value
        $link = $link -replace "/thumbnail/", "/"
        $GSPaperlist.Add($link)
    }
}

DownloadFile $GSPaperlist $GSDir 



