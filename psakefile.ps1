include "./build/general-helpers.ps1"
# include "./build/dotnet-rh-helpers.ps1"

properties {
    $configuration = 'Release'
    $version = '1.0.999'
    $owner = 'Headspring'
    $product = 'Sample Build Script Application'
    $yearInitiated = '2018'
    $projectRootDirectory = "$(resolve-path .)"
    $publish = "$projectRootDirectory/Publish"
    $testResults = "$projectRootDirectory/TestResults"
}

task default -depends Test
task CI -depends Clean, Test, Publish -description "Continuous Integration process"
task Rebuild -depends Clean, Compile -description "Rebuild the code and database, no testing"

task Info -description "Display runtime information" {
    exec { dotnet --info }
}

task Test -depends Compile -description "Run unit tests" {
    get-childitem . src/*.Tests -directory | foreach-object {
        exec { dotnet fixie --configuration $configuration --no-build } -workingDirectory $_.fullname
    }
}
  
task Compile -depends Info -description "Compile the solution" {
    exec { dotnet build --configuration $configuration --nologo -p:"Product=$($product)" -p:"Copyright=$(get-copyright)" -p:"Version=$($version)" } -workingDirectory src
}

task Publish -depends Compile -description "Publish the primary projects for distribution" {
    remove-directory-silently $publish
    exec { publish-project } -workingDirectory src/Sample1.NetCore
}
  
task Clean -description "Clean out all the binary folders" {
    exec { dotnet clean --configuration $configuration /nologo } -workingDirectory src
    remove-directory-silently $publish
    remove-directory-silently $testResults
}
  
task ? -alias help -description "Display help content and possible targets" {
    WriteDocumentation
}
