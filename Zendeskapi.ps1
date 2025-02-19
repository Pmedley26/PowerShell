#Enter the API Token from Zendesk Admin. Email is used or authentication. 
$zendeskApiToken = "Zh2eZh6fNagdM9FM6eqSMntfrkfi79DheXZ90IU6"
$email = "patrickmedley@mtech-systems.com"
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

$response = Invoke-RestMethod -Uri "https://mtechsupport.zendesk.com/api/v2/users.json" -Method Post -Headers $headers -Body $body
$ZendeskUserId = $response.user.id

#Assign the user the Contributor Role 

$body = @{
"role" = "contributor"
} | Convertto-Json

Invoke-RestMethod -Uri "https://mtechsupport.zendesk.com/api/v2/users/$ZendeskUserId.json" -Method Put -Headers $headers -Body $body