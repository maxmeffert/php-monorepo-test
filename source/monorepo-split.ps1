$WorkingDirectory = '.monorepo-split'
$CloneDirectory = "$WorkingDirectory/clone-directory"
$BuildDirectory = "$WorkingDirectory/build-directory"

$PackagePath = "$PSScriptRoot/packages/package-a"
$PackageRepo = 'https://github.com/maxmeffert/php-monorepo-test-package-a.git'

if (Test-Path $WorkingDirectory)
{
  Remove-Item -Force -Recurse $WorkingDirectory | Out-Null
}

New-Item -Force -ItemType Directory -Path $WorkingDirectory | Out-Null
New-Item -Force -ItemType Directory -Path $CloneDirectory | Out-Null
New-Item -Force -ItemType Directory -Path $BuildDirectory | Out-Null


"Cloning $PackageRepo" | Out-Host
git clone $PackageRepo $CloneDirectory

Move-Item -Path $CloneDirectory/.git -Destination $BuildDirectory/.git

Remove-Item -Force -Recurse $CloneDirectory

Get-ChildItem $PackagePath | Copy-Item -Recurse -Destination $BuildDirectory

Push-Location $BuildDirectory

git add .

git status --porcelain

git commit -m 'monorepo split commit'

git push $PackageRepo main

Pop-Location

Remove-Item -Force -Recurse $BuildDirectory