#Enter the API Token from Zendesk Admin. Email is used for authentication. 
#Token left blank for security reasons. Can be accessed in Zendesk Admin under Integration
$zendeskApiToken = ""
$email = "youremail@mtech-systems.com"
$authString = "$($email)/token:$($zendeskApiToken)"
$base64AuthString = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($authString))

$headers = @{
"Authorization" = "Basic $base64AuthString"
"Content-Type" = "application/json"
}



$body = @{
"user" = @{
"name" = read-host -Prompt "Enter User's Name"
"email" = read-host -Prompt "Enter user's Email"
"role" = "end-user"
}
} | Convertto-Json

$response = Invoke-RestMethod -Uri "https://your-domain.zendesk.com/api/v2/users.json" -Method Post -Headers $headers -Body $body
$ZendeskUserId = $response.user.id

#Assign the user the Contributor Role 

$body = @{
"role" = "contributor"
} | Convertto-Json

Invoke-RestMethod -Uri "https://your-domain.zendesk.com/api/v2/users/$ZendeskUserId.json" -Method Put -Headers $headers -Body $body
