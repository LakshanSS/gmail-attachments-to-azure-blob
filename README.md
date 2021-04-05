# Template: Gmail attachements to Azure Blob Storage
When there are attachments in Gmail, upload them to Azure Blob Storage.
 
Whenever you get an email via Gmail with an attachment, this template will save the attachement files in Azure Blob Storage. 
In this way we can gurantee that received attachments are saved in Azure Blob Storage.

## Use this template to
- Save new Gmail attachments to Azure Blob Storage

## What you need
- A Google Cloud Platform Account
- Azure Storage account

## How to set up
- Import the template.
- Allow access to the Gmail.
- Allow access to Azure storage account.
- Set up the template and run.

# Developer Guide
<p align="center">
<img src="./docs/images/gmail_new_attachment_to_azure_blob.png?raw=true" alt="Gmail-Azure Blob Storage Integration template overview"/>
</p>

## Supported versions
<table>
  <tr>
   <td>Ballerina Language Version
   </td>
   <td>Swan Lake Alpha 2
   </td>
  </tr>
  <tr>
   <td>Java Development Kit (JDK) 
   </td>
   <td>11
   </td>
  </tr>
  <tr>
   <td>Gmail API
   </td>
   <td>v1
   </td>
  </tr>
  <tr>
   <td>Azure Storage REST API
   </td>
   <td>2019-12-12
   </td>
  </tr>
</table>

## Pre-requisites
* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* A Google Cloud Platform Account
* Azure Account to Access Azure Portal https://docs.microsoft.com/en-us/learn/modules/create-an-azure-account/
* Azure Storage Account https://docs.microsoft.com/en-us/learn/modules/create-azure-storage-account/
* Ballerina connectors for Gmail and Azure Blob Storage which will be automatically pulled when building the application for the first time.

## Account Configuration
### Configuration of Gmail account
Create a Google account and create a connected app by visiting [Google cloud platform APIs and Services](https://console.cloud.google.com/apis/dashboard). 

1. Click `Library` from the left side bar.
2. In the search bar enter Gmail
3. Then select Gmail API and click `Enable` button.
4. Complete OAuth Consent Screen setup.
5. Click `Credential` tab from left side bar. In the displaying window click `Create Credentials` button
6. Select OAuth client Id.
7. Fill the required field. Add https://developers.google.com/oauthplayground to the Redirect URI field.
8. Get client ID and client secret. Add it to the `Config.toml` file.
9. Visit https://developers.google.com/oauthplayground/ 
    Go to settings (Top right corner) -> Tick 'Use your own OAuth credentials' and insert Oauth client ID and client secret. 
    Click close.
10. Then,Complete step 1 (Select and Authorize APIs)
11. Make sure you select https://mail.google.com/ OAuth scope.
12. Click `Authorize APIs` and You will be in step 2.
13. Exchange Auth code for tokens.
14. Copy `refresh token` and add it to the `Config.toml` file.
15. Add "https://oauth2.googleapis.com/token" as refresh URL in the `Config.toml` file.

### Create push topic and subscription
To use Gmail Listener connector, a topic and a subscription should be configured.

1. Enable Cloud Pub/Sub API for your project which is created in [Google API Console](https://console.developers.google.com).
2. Go to [Google Cloud Pub/Sub API management console](https://console.cloud.google.com/cloudpubsub/topic/list)  and create a topic([You can follow the instructions here](https://cloud.google.com/pubsub/docs/quickstart-console) and a subscription to that topic. The subscription should be a pull subscription in this case ([Find mode details here](https://cloud.google.com/pubsub/docs/subscriber))).
3. For the push subscription , an endpoint URL should be given to push the notification. This URL is the URL where the gmail listener service runs. This should be in `https`  format. (If the service runs in localhost, then ngrok can be used to get an `https` URL).
4. Grant publish right on your topic. [To do this, see the instructions here](https://developers.google.com/gmail/api/guides/push#grant_publish_rights_on_your_topic).

5. Once you have done the above steps, get your topic name (It will be in the format of `projects/<YOUR_PROJECT_NAME>topics/<YOUR_TOPIC_NAME>`) from your console and give it to the `Config.toml` file as `topicName`.

### Configuration of Azure Storage Account
1. Copy one of the Access Keys from the Azure Portal and add it to `Config.toml` file as `accessKeyOrSAS`.
2. Add azure storage account name to `Config.toml` file as `accountName`.
3. Create a container and add the name of the container to `Config.toml` file as `containerName`.

## Config.toml 
```
[<ORG_NAME>.gmail_new_attachment_to_azure_blob]
port = <PORT>
topicName = "<TOPIC_NAME>"
accessKeyOrSAS = "<AZURE_ACCESS_KEY>"
accountName = "<AZURE_STORAGE_ACCOUNT_NAME>"
containerName = "<CONTAINER_NAME>"


[<ORG_NAME>.gmail_new_attachment_to_azure_blob.gmailOauthConfig]
clientId = "<CLIENT_ID>"
clientSecret = "<CLIENT_SECRET>"
refreshUrl = "<GMAIL_REFRESH_URL>"
refreshToken = "<REFRESH_TOKEN>"
```
## Running the template
1. First you need to build the integration template and create the executable binary. Run the following command from the 
   root directory of the integration template. 
`$ bal build`. 

2. Then you can run the integration binary with the following command. 
`$ target/bin/gmail_new_attachment_to_azure_blob-0.1.0.jar`. 

Successful listener startup will print following in the console.
```
time = 2021-03-31 13:14:59,554 level = INFO  module = ballerinax/googleapis_gmail.listener message = "Starting History ID: 1421158" 
[ballerina/http] started HTTP/WS listener 0.0.0.0:8080
time = 2021-03-31 13:15:00,533 level = ERROR module = ballerinax/googleapis_gmail message = "Error occurred while getting history list" error = "{ballerina/lang.map}KeyNotFound" 
time = 2021-03-31 13:15:00,538 level = INFO  module = ballerinax/googleapis_gmail.listener message = "Next History ID = 1421160" 
```
**Note :** The `"{ballerina/lang.map}KeyNotFound"` error will not affect the usability of the template

3. Now you can send a new email with an attachment and observe if integration template runtime has 
   logged the status of the response.

4. You can check the Azure Blob Storage Container to  verify if a new file is created. 
