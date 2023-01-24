#!/bin/bash -e

# 変数を定義する
region='japaneast'                       # デプロイ先のリージョン
resourceGroupName=$1                     # デプロイ先のリソースグループ (スクリプトの引数から取得する)
uploadedBlobContainerName='uploaddata'   # ビデオファイルアップロードに使用する Blob コンテナ名
analyzedBlobContainerName='analyzed'     # Video Indexer での分析結果の JSON ファイルを格納する Blob コンテナ名
cognitiveSearchIndexName='video-phrases' # Cognitive Search のインデックス名
logicAppTriggerName='webhook'            # Logic Apps のワークフロー定義でのトリガーの名前

# リソースグループを作成する
az group create \
    --location $region \
    --resource-group $resourceGroupName

# Azure リソース(Storage, Video Indexer, Media Services, Cognitive Search, Functionsなど)をデプロイする
outputs=($(az deployment group create \
            --resource-group $resourceGroupName \
            --template-file biceps/deploy.bicep \
            --parameters uploadedBlobContainerName=$uploadedBlobContainerName \
                         analyzedBlobContainerName=$analyzedBlobContainerName \
            --query 'properties.outputs.*.value' \
            --output tsv))
tenantId=`echo ${outputs[0]}` # 文末の \r を削除する
subscriptionId=`echo ${outputs[1]}` # 文末の \r を削除する
storageAccountName=`echo ${outputs[2]}` # 文末の \r を削除する
functionAppName=`echo ${outputs[3]}` # 文末の \r を削除する
staticWebAppName=`echo ${outputs[4]}` # 文末の \r を削除する
staticWebAppHostName=`echo ${outputs[5]}` # 文末の \r を削除する
cognitiveSearchName=`echo ${outputs[6]}` # 文末の \r を削除する
cognitiveServiceName=`echo ${outputs[7]}` # 文末の \r を削除する
videoIndexerResourceId=`echo ${outputs[8]}` # 文末の \r を削除する
videoIndexerAccountId=`echo ${outputs[9]}` # 文末の \r を削除する
videoIndexerLocation=`echo ${outputs[10]}` # 文末の \r を削除する
logicAppName=`echo ${outputs[11]}` # 文末の \r を削除する
logicAppConnectionId=${outputs[12]}

# Cognitive Service の API キーを取得する
cognitiveServiceKey=`az cognitiveservices account keys list --name $cognitiveServiceName --resource-group $resourceGroupName --query 'key1' --output tsv`

# Cognitive Search の API キーを取得する
cognitiveSearchApiKey=`az search admin-key show --service-name $cognitiveSearchName --resource-group $resourceGroupName --query 'primaryKey' --output tsv`

# Cognitive Search インデックスを作成する
cognitiveSearchIndexName="video-phrases"
curl -X PUT https://$cognitiveSearchName.search.windows.net/indexes/$cognitiveSearchIndexName?api-version=2020-06-30 \
    -H 'Content-Type: application/json' \
    -H 'api-key: '$cognitiveSearchApiKey \
    -d @cogsearch/index.json

# Cognitive Search データソースを作成する
cognitiveSearchDataSourceName="video-phrases"
curl -X PUT https://$cognitiveSearchName.search.windows.net/datasources/$cognitiveSearchDataSourceName?api-version=2020-06-30 \
    -H 'Content-Type: application/json' \
    -H 'api-key: '$cognitiveSearchApiKey \
    -d "$(sed -e "s|{{CONNECTION_STRING}}|ResourceId=/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageAccountName;|; \
                  s|{{CONTAINER_NAME}}|$analyzedBlobContainerName|;" \
                  "cogsearch/datasource.json")"

# Cognitive Search スキルセットを作成する
cognitiveSearchSkillSetName="video-phrases"
curl -X PUT https://$cognitiveSearchName.search.windows.net/skillsets/$cognitiveSearchSkillSetName?api-version=2020-06-30 \
    -H 'Content-Type: application/json' \
    -H 'api-key: '$cognitiveSearchApiKey \
    -d "$(sed -e "s|{{COGNITIVE_SERVICE_KEY}}|$cognitiveServiceKey|;" \
                  "cogsearch/skillset.json")"


# Cognitive Search インデクサーを作成する
cognitiveSearchIndexerName="video-phrases"
curl -X PUT https://$cognitiveSearchName.search.windows.net/indexers/$cognitiveSearchIndexerName?api-version=2020-06-30 \
    -H 'Content-Type: application/json' \
    -H 'api-key: '$cognitiveSearchApiKey \
    -d "$(sed -e "s|{{DATASOURCE_NAME}}|$cognitiveSearchDataSourceName|; \
                  s|{{SKILLSET_NAME}}|$cognitiveSearchSkillSetName|; \
                  s|{{INDEX_NAME}}|$cognitiveSearchIndexName|;" \
                  "cogsearch/indexer.json")"

# Azure Functions のアプリケーションをデプロイする
pushd functions
sleep 10 # Azure Functions App リソースの作成からコードデプロイが早すぎると「リソースが見つからない」エラーが発生する場合があるので、一時停止する
func azure functionapp publish $functionAppName --csharp
popd

# Azure Logic Apps のワークフローの定義をテンプレートから作成する
sed -e " \
    s|{{VIDEO_INDEXER_RESOURCE_ID}}|$videoIndexerResourceId|; \
    s|{{VIDEO_INDEXER_ACCOUNT_ID}}|$videoIndexerAccountId|; \
    s|{{VIDEO_INDEXER_LOCATION}}|$videoIndexerLocation|; \
    s|{{COGNITIVE_SEARCH_NAME}}|$cognitiveSearchName|; \
    s|{{COGNITIVE_API_KEY}}|$cognitiveSearchApiKey|; \
    s|{{COGNITIVE_SEARCH_INDEXER_NAME}}|$cognitiveSearchIndexerName|; \
    s|{{COGNITIVE_SEARCH_DATASOURCE_CONTAINER}}|$analyzedBlobContainerName|; \
    s|{{LOGIC_APP_TRIGGER_NAME}}|$logicAppTriggerName|; \
    s|{{LOGIC_APP_CONNECTION_RESOURCE_ID}}|$logicAppConnectionId|; \
    s|{{SUBSCRIPTION_ID}}|$subscriptionId|; \
    s|{{REGION}}|$region|; \
" "logicapp/definition_template.json" > "logicapp/definition.json"

# Azure Logic Apps のワークフローの定義をする
az logic workflow create \
    --location $region \
    --resource-group $resourceGroupName \
    --name $logicAppName \
    --definition "logicapp/definition.json"

# Azure リソース(EventGrid)をデプロイする
az deployment group create \
    --resource-group $resourceGroupName \
    --template-file biceps/post-deploy.bicep \
    --parameters storageAccountName=$storageAccountName \
                 blobContainerName=$uploadedBlobContainerName \
                 logicAppName=$logicAppName \
                 logicAppTriggerName=$logicAppTriggerName

# Cognitive Search へアクセスするためのクエリキーを取得する
cognitiveSearchQueryKey=`az search query-key list --resource-group $resourceGroupName --service-name $cognitiveSearchName --query "[0].key" --output tsv`

# Web アプリで使用する情報を JSON ファイルとして出力する
echo "{ 
    \"cognitiveSearchName\": \"$cognitiveSearchName\", 
    \"cognitiveSearchIndexName\": \"$cognitiveSearchIndexName\", 
    \"cognitiveSearchQueryKey\": \"$cognitiveSearchQueryKey\",
    \"suggesterName\": \"sg\",
    \"facetNames\": {},
    \"apiVersion\": \"2020-06-30\",
    \"searchTop\": 5,
    \"suggestionTop\": 5,
    \"highlight\": \"phrase\",
    \"highlightPreTag\": \"<span class='bg-warning'>\",
    \"highlightPostTag\": \"</span>\"
}" > app/src/assets/cogsearch_settings.json

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

# Vue アプリをビルドする
pushd app
npm install
npm run build
popd

# テンプレートから "staticwebapp.config.json" ファイルを作成する
sed -e "s/{{AZURE_TENANT_ID}}/$tenantId/g" "app/staticwebapp.config_template.json" > app/dist/staticwebapp.config.json

# HTML アプリを Static Apps へデプロイする
swa deploy \
    --app-location 'app/dist' \
    --tenant-id $tenantId \
    --resource-group $resourceGroupName \
    --app-name $staticWebAppName \
    --env 'production'

echo ''
echo 'https://'$staticWebAppHostName'/upload.html を Web ブラウザで開いて mp4 ビデオファイルをアップロードしてください。'
echo 'Azure Video Indexer での文字起こしが完了すると、'https://$staticWebAppHostName' で指定した文言を話しているビデオファイルを検索することができます。'