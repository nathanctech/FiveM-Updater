##################################################
### FiveM Automatic Updater
###
###
### V: 1.2
###
### Updates/Support: https://github.com/nathanctech/FiveM-Updater
###
###
### Licensed under MIT license. See LICENSE. 
### Do not distribute without license and header.
###
###
### Changelog
###
### V1.2
### - Change URL used due to API changes
###
### V1.1
### - Ensure new artifact can be downloaded before removing old files
### - Exempt .zip files from purge
### - Added -KeepDownload flag, specifying will keep the newly downloaded artifact zip.
### - Exempt .crt and .key from purge so custom-signed certs are never deleted.
#################################################

param (
    [switch]$Silent = $false,  # prompt for update
    [switch]$KeepDownload = $false # keeps downloaded zip
)


### EDIT BELOW CONFIGURATION

# ABSOLUTE path to where FXServer.exe is located (or you want it to be created)

$artifactFolder = "C:\FiveM\development\binaries"

# FIRST TIME USE ONLY - ENTER SERVER VERSION IF YOU HAVE A SERVER INSTALLED IN THE ABOVE PATH.
# Type "version" into the console to see, then enter the 4 digit version.

$initialVersion = 1

# Delete Exclusion Filter
# Add folders or files to exclude from deletion. Wildcards accepted.

$filter = @("*.cfg","*.cmd","*.bat","*.zip","*.crt", "*.key", "resources","cache")


### DO NOT EDIT ANYTHING PAST THIS LINE ###

function Get-Latest-Release {
	[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    $obj = Invoke-WebRequest "https://api.github.com/repos/citizenfx/fivem/git/refs/tags" -Headers @{"accept"="application/vnd.github.v3+json"} -UseBasicParsing | ConvertFrom-Json
    $last = ($obj | ? {$_.ref -like "refs/tags/v1.0.0.*"} | Select-Object -Last 1)
    $tag = Invoke-WebRequest $last.object.url -Headers @{"accept"="application/vnd.github.v3+json"} -UseBasicParsing | ConvertFrom-Json
    $hash = $tag.object.sha
    $version = $tag.tag -replace "v1.0.0."
    $fullUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/" + $version + "-" + $hash + "/server.zip"
    $releaseObj = New-Object -TypeName psobject
    $releaseObj | Add-Member -MemberType NoteProperty -Name Uri -Value $fullUrl 
    $releaseObj | Add-Member -MemberType NoteProperty -Name Version -Value $version
    $releaseObj | Add-Member -MemberType NoteProperty -Name Hash -Value $hash
    return $releaseObj
}

echo "### FiveM Automatic Updater ###"

$latestArtifact = 0

# attempt to get latest version
$latest = Get-Content -Path $artifactFolder/current-version -ErrorAction SilentlyContinue
$latest = [int]$latest

echo "Detected version is $latest..."
if ($latest -eq 0) {
    echo "No current version detected. Using initial version."
    $latestArtifact = $initialVersion
} else {
    $latestArtifact = $latest
}

echo "The current version on server is $latestArtifact.. Checking the artifacts server."

$latestRelease = Get-Latest-Release
$doDownload = $false

$latestArtifact = $latestRelease.Version
$latestUrl = $latestRelease.Uri

if ($latestArtifact -ne $latest)
{
	if ($Silent -eq $false) {
            $choice = Read-Host -Prompt "The latest artifact is $latestArtifact. Do you want to install? (y/n)."
	        if($choice -eq "y") { # They want to update
		        $doDownload = $true
        }
	}
    else { 
        $doDownload = $true
    }
}

If ($doDownload -eq 1){

    if (-not  (Test-Path -Path $artifactFolder -PathType Container)) {
        try {
            New-Item -Path $artifactFolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
        }
        catch {
            Write-Error -Message "Unable to create directory '$artifactFolder'. Error was: $_" -ErrorAction Stop
        }
    }

	echo "Downloading artifact $latestArtifact located at $latestUrl"
	$dest = "$artifactFolder\$latestArtifact.zip"
	try {
	    $wc = New-Object System.Net.WebClient
	    $wc.DownloadFile($latestUrl, $dest)
    } catch {
        Write-Error "Unable to download latest artifact. It may not be available yet or was revoked. Error was: $_" -ErrorAction Stop
    }

    echo "Removing old files"
    cd $artifactFolder
    Get-ChildItem -Exclude $filter -Force | Remove-Item -Force -Recurse

	$d = "$artifactFolder"
	
	Expand-Archive $dest -DestinationPath $d -Force
	$latest = "$latestArtifact"
	echo $latest | Out-File -FilePath $artifactFolder/current-version
    if ($KeepDownload -eq $false) {
        del $dest
    }

    echo "Update completed."
}
