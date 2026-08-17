# note: I gave up on this. what a quagmire

# app registration worked from entra web page, but probably easier from pwsh

connect-azuread

$MSGraph = Get-AzureADServicePrincipal -All $true | ? { $_.DisplayName -eq "Microsoft Graph" }

$MSGraph.Oauth2Permissions | ? { `
($_.Value -eq "email") `
-or ($_.Value -eq "offline_access") `
-or ($_.Value -eq "openid") `
-or ($_.Value -eq "profile") `
} | Format-Table ID, Value

# Id                                   Value
# --                                   -----
# 64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0 email
# 7427e0e9-2fba-42fe-b0c0-848c9e6a8182 offline_access
# 37f7f235-527c-4136-accd-4a02d197296e openid
# 14dad69e-099b-42c9-810b-d002981feec1 profile

$app = Get-AzureADApplication | ? {$_.displayname -eq "mailflow"}
$appId = $app.ObjectId

$Graph = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$Graph.ResourceAppId = $MSGraph.AppId

$profile_perm = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "14dad69e-099b-42c9-810b-d002981feec1","Scope"
$offline_access_perm = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "7427e0e9-2fba-42fe-b0c0-848c9e6a8182","Scope"
$openid_perm = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "37f7f235-527c-4136-accd-4a02d197296e","Scope"
$email_perm = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0","Scope"
$Graph.ResourceAccess = $profile_perm, $offline_access_perm, $openid_perm, $email_perm

Set-AzureADApplication -ObjectId $appId -RequiredResourceAccess $Graph -Oauth2AllowImplicitFlow $true

# az ad app show --id $appId

# running the create command will patch an existing one?? matching on display name?? wtf are these ppl smoking
az ad app create --display-name "mailflow" --sign-in-audience "AzureADMyOrg"

# after setting the perms, you need to patch the audience back to "AzureADandPersonalMicrosoftAccount"
# AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, PersonalMicrosoftAccount

# you also need to patch the sign-in audience to "AzureADMyOrg" in order to delete the app registartion.
# WHAT A JOKE
