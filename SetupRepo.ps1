Param(
	[Parameter(Mandatory=$true, HelpMessage="Repository Name")]
	[string]$repoName,

	[Parameter(Mandatory=$true, HelpMessage="GitHub Username")]
	[string]$githubUsername,

	[Parameter(Mandatory=$true, HelpMessage="GitHub Password")]
	[Security.SecureString]$githubPassword,
	
	[bool]$create = $true,
	[bool]$gradle = $false,
	[string]$repoFolder = "$env:userprofile\Documents\Git Repos"
)

# Taking a secure password and converting to plain text
# Taken from http://serverfault.com/questions/406933/powershell-parameters
Function ConvertTo-PlainText( [security.securestring]$secure ) {
	$marshal = [Runtime.InteropServices.Marshal]
	$marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($secure) )
}

$githubPasswordPlain = ConvertTo-PlainText $githubPassword

# Move to the defined repo folder
Set-Location $repoFolder

if ($create) {
	# Prepare to send a POST request to GitHub to create the repo
	$url = 'https://api.github.com/user/repos';
	$basiccredential = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes([String]::Format("{0}:{1}", $githubUsername, $githubPasswordPlain)))
	$header = @{
		Method = 'POST';
		Accept = 'application/vnd.github.v3+json';
		Authorization = "Basic " + $basiccredential;
	}
	$body = @{
		name = $repoName;
		auto_init = $true;
	} | ConvertTo-Json

	Invoke-WebRequest $url -Method POST -Headers $header -Body $body
}

# Now that we have the repo created, time to clone
$repoUrl = "https://github.com/dmillerw/$repoName.git"

# Clone
git clone $repoUrl

# Check for the existance of the MainGradle repo
if ((Test-Path -path "$repoFolder\MainGradle\") -ne $true) {
	# Doesn't exist, so clone it
	git clone "https://github.com/dmillerw/MainGradle.git"
}

# Move into the MainGradle directory
Set-Location "MainGradle"

# Ensure we're up to date
git pull

# Copy contents to new repo folder (excluding main.gradle and SetupRepo.ps1)
$exclusion = @('.git', 'main.gradle', '*.ps1')
Copy-Item * ../$repoName/ -Recurse -Force -Exclude $exclusion

Set-Location ../$repoName/

if ($gradle) {
	# Finally, open the new build.properties file for editing, and wait for it to be closed before continuing
	Start-Process Notepad.exe "build.properties" -Wait
	
	# Execute main gradle tasks
	.\gradlew setupDecompWorkspace
	.\gradlew idea
} else {
	# Finally, open the new build.properties file for editing
	notepad "build.properties"
}