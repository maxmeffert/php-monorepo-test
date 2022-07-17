function Publish-Package($PackagePath, $PackageRepo)
{

  "===========================================" | Write-Host -ForegroundColor Cyan
  "Publish-Package" | Write-Host -ForegroundColor Cyan
  "===========================================" | Write-Host -ForegroundColor Cyan
  "PackagePath $PackagePath" | Write-Host -ForegroundColor Cyan
  "PublishRepo $PackageRepo" | Write-Host -ForegroundColor Cyan

  $WorkingDirectory = '.monorepo-split'
  $CloneDirectory = "$WorkingDirectory/clone-directory"
  $BuildDirectory = "$WorkingDirectory/build-directory"

  if (Test-Path $WorkingDirectory)
  {
    Remove-Item -Force -Recurse $WorkingDirectory | Out-Null
  }

  New-Item -Force -ItemType Directory -Path $WorkingDirectory | Out-Null
  New-Item -Force -ItemType Directory -Path $CloneDirectory | Out-Null
  New-Item -Force -ItemType Directory -Path $BuildDirectory | Out-Null


  "Clone upstream repository: $PackageRepo" | Write-Host -ForegroundColor Cyan
  git clone $PackageRepo $CloneDirectory

  "Move .git folder from $CloneDirectory to $BuildDirectory" | Write-Host -ForegroundColor Cyan
  Move-Item -Path $CloneDirectory/.git -Destination $BuildDirectory/.git

  "Remove $CloneDirectory" | Write-Host -ForegroundColor Cyan
  Remove-Item -Force -Recurse $CloneDirectory

  "Copy items from $PackagePath to $BuildDirectory" | Write-Host -ForegroundColor Cyan
  Get-ChildItem $PackagePath | Copy-Item -Recurse -Destination $BuildDirectory


  "Change location to $BuildDirectory" | Write-Host -ForegroundColor Cyan
  Push-Location $BuildDirectory

  "Add changes" | Write-Host -ForegroundColor Cyan
  git add .
  git status --porcelain


  "Push changes to $PackageRepo" | Write-Host -ForegroundColor Cyan
  git commit -m 'monorepo split commit'
  git push $PackageRepo main

  Pop-Location

  "Cleanup" | Write-Host -ForegroundColor Cyan
  Remove-Item -Force -Recurse $BuildDirectory
}

Publish-Package -PackagePath "$PSScriptRoot/packages/package-a" -PackageRepo 'https://github.com/maxmeffert/php-monorepo-test-package-a.git'
Publish-Package -PackagePath "$PSScriptRoot/packages/package-b" -PackageRepo 'https://github.com/maxmeffert/php-monorepo-test-package-b.git'