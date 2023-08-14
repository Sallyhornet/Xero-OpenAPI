#!/bin/bash
set -euxo pipefail

SCRIPT="$0"
echo "# START SCRIPT: $SCRIPT"

#./openapi-generator-check.sh || exit 1

# remote yaml on github branch "oauth"
ags="generate 
-t ./generator/modules/csharp-dotnet
-i https://raw.githubusercontent.com/XeroAPI/Xero-OpenAPI/master/accounting-yaml/Xero_accounting_2.0.0_swagger.yaml 
-g csharp-dotnet
-o ./generator/output/csharp-dotnet/accounting
-c ./generator/scripts/dotnet-oauth2-accounting.json
-p debugModels=false
-p hideGenerationTimestamp=true
$@"

echo "Removing files and folders under output/output/csharp-dotnet"
rm -rf ./generator/output/csharp-dotnet/accounting
openapi-generator $ags  
# hacky way of fixing some things without editing the templating engine
rm -rf generator/output/csharp-dotnet/accounting/src/Xero.DotNet.OAuth2/project.json
# following to make it compatible with VS2019
sed -e 's/<TargetFramework>net6.0<\/TargetFramework>/g' -i generator/output/csharp-dotnet/accounting/src/Xero.DotNet.OAuth2/Xero.DotNet.OAuth2.csproj
# fix emitdefaultvalue for models
find generator/output/csharp-dotnet/accounting/src/Xero.DotNet.OAuth2/Model/*.cs -type f | xargs sed -e 's/string? /string /g' -i
find generator/output/csharp-dotnet/accounting/src/Xero.DotNet.OAuth2/Model/*.cs -type f | xargs sed -e 's/DateTime?? /DateTime? /g' -i
find generator/output/csharp-dotnet/accounting/src/Xero.DotNet.OAuth2/Model/*.cs -type f | xargs sed -e 's/Guid?? /Guid? /g' -i
find generator/output/csharp-dotnet/accounting/src/Xero.DotNet.OAuth2/Model/*.cs -type f | xargs sed -e 's/List<string>? /List<string> /g' -i
