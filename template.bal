import ballerina/encoding;
import ballerina/http;
import ballerina/log;
import ballerina/time;
import lakshans/azure_storage_service.blobs as azure_blobs;
import ballerinax/googleapis_gmail as gmail;
import ballerinax/googleapis_gmail.'listener as gmailListener;

// Azure Blob Configuration
configurable string & readonly accessKeyOrSAS  = ?;
configurable string & readonly accountName = ?; 
configurable string & readonly containerName = ?;


// Gmail Configuration
configurable http:OAuth2DirectTokenConfig & readonly gmailOauthConfig = ?;
configurable int & readonly port = ?;
configurable string & readonly topicName = ?;

// Azure Blob Client Initialization
azure_blobs:AzureBlobServiceConfiguration blobServiceConfig = {
        accessKeyOrSAS: accessKeyOrSAS,
        accountName: accountName,
        authorizationMethod: "accessKey"
};
azure_blobs:BlobClient blobClient = check new (blobServiceConfig);

// Gmail Client Initialization
gmail:GmailConfiguration gmailClientConfiguration = {
    oauthClientConfig: gmailOauthConfig
};
gmail:Client gmailClient = new (gmailClientConfiguration);

// Gmail listener
listener gmailListener:Listener gmailEventListener = new(port, gmailClient, topicName);

service / on gmailEventListener {
    resource function post subscription(http:Caller caller, http:Request req) returns error? {
        var response = gmailEventListener.onMailboxChanges(caller, req);
        if (response is gmail:MailboxHistoryPage) {
            var triggerResponse = gmailEventListener.onNewAttachment(response);
            if (triggerResponse is gmail:MessageBodyPart[]) {
                if (triggerResponse.length() > 0) {
                    foreach var attachment in triggerResponse {
                        byte[] content = check encoding:decodeBase64Url(attachment.body);
                        string fileName = "File-" + time:currentTime().time.toString();
                        var putBlobResult = blobClient->putBlob(containerName, fileName, "BlockBlob", content);
                        if (putBlobResult is error) {
                            log:printError(putBlobResult.toString());
                        } else {
                            log:print(putBlobResult.toString());
                            log:print(fileName + "added uploaded successfully");
                        }
                    }
                }
            }
        }
    }     
}
