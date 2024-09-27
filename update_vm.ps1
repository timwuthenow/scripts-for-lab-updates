# PowerShell script to update VMs

# Function to download and install Java 17 LTS Semeru Runtime
function Install-Java17 {
    $javaUrl = "https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.6%2B10_openj9-0.36.0/ibm-semeru-open-jdk_x64_windows_17.0.6_10_openj9-0.36.0.msi"
    $javaInstaller = "$env:TEMP\java17_semeru.msi"
    Invoke-WebRequest -Uri $javaUrl -OutFile $javaInstaller
    Start-Process msiexec.exe -ArgumentList "/i $javaInstaller /qn" -Wait
    Remove-Item $javaInstaller
}

# Function to update Maven to 3.9.7
function Update-Maven {
    $mavenUrl = "https://dlcdn.apache.org/maven/maven-3/3.9.7/binaries/apache-maven-3.9.7-bin.zip"
    $mavenZip = "$env:TEMP\maven-3.9.7.zip"
    $mavenDir = "C:\Program Files\Apache\maven"

    Invoke-WebRequest -Uri $mavenUrl -OutFile $mavenZip
    Expand-Archive -Path $mavenZip -DestinationPath $env:TEMP -Force
    
    if (Test-Path $mavenDir) {
        Remove-Item $mavenDir -Recurse -Force
    }
    
    Move-Item "$env:TEMP\apache-maven-3.9.7" $mavenDir
    Remove-Item $mavenZip

    # Update PATH
    $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    $newPath = "$mavenDir\bin;" + $path
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
}

# Function to update Chrome bookmarks
function Update-ChromeBookmarks {
    $bookmarksFile = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
    
    if (Test-Path $bookmarksFile) {
        # Backup existing bookmarks
        Copy-Item $bookmarksFile "$bookmarksFile.bak"
        
        # Load bookmarks JSON
        $bookmarks = Get-Content $bookmarksFile | ConvertFrom-Json
        
        # Update bookmarks here
        # Example: updating a bookmark URL
        # $bookmarks.roots.bookmark_bar.children | Where-Object { $_.name -eq "Example" } | ForEach-Object { $_.url = "https://new-url.com" }
        
        # Save updated bookmarks
        $bookmarks | ConvertTo-Json -Depth 100 | Set-Content $bookmarksFile
    } else {
        Write-Host "Chrome bookmarks file not found."
    }
}

# Function to install Podman Desktop
function Install-PodmanDesktop {
    $podmanUrl = "https://github.com/containers/podman-desktop/releases/latest/download/podman-desktop-setup.exe"
    $podmanInstaller = "$env:TEMP\podman-desktop-setup.exe"
    Invoke-WebRequest -Uri $podmanUrl -OutFile $podmanInstaller
    Start-Process $podmanInstaller -ArgumentList "/S" -Wait
    Remove-Item $podmanInstaller
}

# Main execution
Install-Java17
Update-Maven
Update-ChromeBookmarks
Install-PodmanDesktop

Write-Host "All updates completed successfully."
