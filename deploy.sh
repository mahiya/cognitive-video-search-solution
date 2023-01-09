#!/bin/bash -e

# 変数を定義する
region='japaneast'                       # デプロイ先のリージョン
resourceGroupName=$1                     # デプロイ先のリソースグループ (スクリプトの引数から取得する)
blobContainerName='uploaddata'           # ビデオファイルアップロードに使用する Blob コンテナ名
cognitiveSearchIndexName='video-phrases' # Cognitive Search のインデックス名
functionName='ProcessUploadedData'       # Azure Functions アプリケーションコードで指定したものと同じにする

# リソースグループを作成する
az group create \
    --location $region \
    --resource-group $resourceGroupName

# Azure リソース(Storage, Video Indexer, Media Services, Cognitive Search, Functionsなど)をデプロイする
outputs=($(az deployment group create \
            --resource-group $resourceGroupName \
            --template-file biceps/deploy.bicep \
            --parameters blobContainerName=$blobContainerName \
                         cognitiveSearchIndexName=$cognitiveSearchIndexName \
            --query 'properties.outputs.*.value' \
            --output tsv))
tenantId=`echo ${outputs[0]}` # 文末の \r を削除する
storageAccountName=`echo ${outputs[1]}` # 文末の \r を削除する
functionAppForWorkflowName=`echo ${outputs[2]}` # 文末の \r を削除する
functionAppForWebApiName=`echo ${outputs[3]}` # 文末の \r を削除する
staticWebAppName=`echo ${outputs[4]}` # 文末の \r を削除する
staticWebAppHostName=`echo ${outputs[5]}` # 文末の \r を削除する
cognitiveSearchName=`echo ${outputs[6]}` # 文末の \r を削除する
videoIndexerAccountId=`echo ${outputs[7]}` # 文末の \r を削除する
videoIndexerLocation=${outputs[8]}

# Azure Functions のアプリケーションをデプロイする
pushd functions/Workflow
sleep 10 # Azure Functions App リソースの作成からコードデプロイが早すぎると「リソースが見つからない」エラーが発生する場合があるので、一時停止する
func azure functionapp publish $functionAppForWorkflowName --csharp
popd

pushd functions/WebApi
func azure functionapp publish $functionAppForWebApiName --csharp
popd

# Azure リソース(EventGrid)をデプロイする
az deployment group create \
    --resource-group $resourceGroupName \
    --template-file biceps/post-deploy.bicep \
    --parameters storageAccountName=$storageAccountName \
                 blobContainerName=$blobContainerName \
                 functionAppName=$functionAppForWorkflowName \
                 functionName=$functionName

# Cognitive Search のインデックスを作成する
cognitiveSearchApiKey=`az search admin-key show --service-name $cognitiveSearchName --resource-group $resourceGroupName --query 'primaryKey' --output tsv`
curl -X PUT https://$cognitiveSearchName.search.windows.net/indexes/$cognitiveSearchIndexName?api-version=2020-06-30 \
    -H 'Content-Type: application/json' \
    -H 'api-key: '$cognitiveSearchApiKey \
    -d @cogsearch/index.json

# Cognitive Search へアクセスするためのクエリキーを取得する
cognitiveSearchQueryKey=`az search query-key list --resource-group $resourceGroupName --service-name $cognitiveSearchName --query "[0].key" --output tsv`

# Web アプリで使用する情報を JSON ファイルとして出力する
echo "{ 
    \"cognitiveSearchName\": \"$cognitiveSearchName\", 
    \"cognitiveSearchIndexName\": \"$cognitiveSearchIndexName\", 
    \"cognitiveSearchQueryKey\": \"$cognitiveSearchQueryKey\",
    \"facetNames\": {},
    \"apiVersion\": \"2020-06-30\",
    \"searchTop\": 5,
    \"suggestionTop\": 5,
    \"highlight\": \"phrase\",
    \"highlightPreTag\": \"<span class='bg-warning'>\",
    \"highlightPostTag\": \"</span>\"
}" > htmls/cogsearch_settings.json

# Static Web Apps で使用する AAD アプリを登録する
aadClientId=`az ad app create \
                --display-name $staticWebAppName \
                --sign-in-audience AzureADMyOrg \
                --enable-id-token-issuance true \
                --enable-access-token-issuance false \
                --web-redirect-uris "https://$staticWebAppHostName/.auth/login/aad/callback" \
                --query 'appId' \
                --output tsv`

# Static Web Apps で使用するクライアントシークレットを作成する
aadClientSecret=`az ad app credential reset \
                    --id $aadClientId \
                    --query 'password' \
                    --output tsv`

# Static Web Apps の設定にクライアントIDとクライアントシークレットを設定する
az staticwebapp appsettings set \
    --resource-group $resourceGroupName \
    --name $staticWebAppName \
    --setting-names AZURE_CLIENT_ID=$aadClientId \
                    AZURE_CLIENT_SECRET=$aadClientSecret

# テンプレートから "staticwebapp.config.json" ファイルを作成する
sed -e "s/{{AZURE_TENANT_ID}}/$tenantId/g" "htmls/staticwebapp.config_template.json" > htmls/staticwebapp.config.json

# HTML アプリを Static Apps へデプロイする
swa deploy \
    --app-location './htmls' \
    --tenant-id $tenantId \
    --resource-group $resourceGroupName \
    --app-name $staticWebAppName \
    --env 'production'

echo ''
echo 'https://'$staticWebAppHostName'/upload.html を Web ブラウザで開いて mp4 ビデオファイルをアップロードしてください。'
echo 'Azure Video Indexer での文字起こしが完了すると、'https://$staticWebAppHostName' で指定した文言を話しているビデオファイルを検索することができます。'