# dotnet-rh-helpers

# Add these properties to psakefile.ps1:
# $ci_db_connectionString = $env:Sample1:ConnectionStrings:Database
# $db_connectionStrings = @{
#     DEV = Get-Connection-String $product src/$product.Web/appsettings.json;
#     TEST = Get-Connection-String $product src/$product.Tests/appsettings.json;
# }
#
# And don't forget to add the tasks as dependent where applicable

task UpdateDatabase -alias udb -description "Run migrations scripts" {
    exec { dotnet rh -cs $db_connectionStrings["DEV"] -f $db_scripts --env "DEV" --silent }
    exec { dotnet rh -cs $db_connectionStrings["TEST"] -f $db_scripts --env "TEST" --silent }
}

task RebuildDatabase -alias rebuild -description "Drop database and execute all migration scripts" {
    exec { dotnet rh -cs $db_connectionStrings["DEV"] --env "DEV" --drop --silent }
    exec { dotnet rh -cs $db_connectionStrings["DEV"] -f $db_scripts --env "DEV" --silent }
    exec { dotnet rh -cs $db_connectionStrings["TEST"] --env "TEST" --drop --silent }
    exec { dotnet rh -cs $db_connectionStrings["TEST"] -f $db_scripts --env "TEST" --silent }
}

task CI_RebuildDatabase -description "Run migration scripts on CI build agent" {
    exec { dotnet rh -cs "$ci_db_connectionString" --env "TEST" --silent --drop }
    exec { dotnet rh -cs "$ci_db_connectionString" --env "TEST" --silent -f $db_scripts  }
}

function Get-Connection-String($environmentVariablePrefix, $appsettingsPath) {
    $environmentVariableName = "$($environmentVariablePrefix):ConnectionStrings:Database"

    if (test-path env:$environmentVariableName) {
        return (get-item env:$environmentVariableName).Value
    }

    return (get-content $appsettingsPath | out-string | convertfrom-json).ConnectionStrings.Database
}
