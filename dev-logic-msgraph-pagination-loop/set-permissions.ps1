# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.Read.All","AppRoleAssignment.ReadWrite.All" -UseDeviceCode

# Save the service principal object to a variable for ease of use
$ADO_Svc_Principal = Get-MgServicePrincipal -Filter "displayName eq 'dev-logic-msgraph-nextLink-template'"


# Replace with your managed identity object ID
$miObjectID = $ADO_Svc_Principal.Id

# The app ID of the API where you want to assign the permissions - the below is for Microsoft Graph
$appId = "00000003-0000-0000-c000-000000000000"

# Replace with the API permissions required by your app
# The below permissions will allow the app to retrieve a list of all users in your environment ["User.Read.All"] and their loginActivity ["AuditLog.Read.All"]
# Additional permissions may be required to retrieve additional information - group memberships ["Group.Read.All"], or modify their properties ["User.RevokeSessions.All"]
$permissionsToAdd = "User.Read.All","AuditLog.Read.All"


# Retrieve the REST API object on which permissions will be granted
$app = Get-MgServicePrincipalByAppId -appid $appId

#Loop through the list of desired $permissionsToAdd and assign each to the managed identity.
foreach ($permission in $permissionsToAdd)
{
    $role = $app.AppRoles | where Value -Like $permission | Select-Object -First 1
    New-MgServicePrincipalAppRoleAssignment -AppRoleId $role.Id -ServicePrincipalId $miObjectID -PrincipalId $miObjectID -ResourceId $app.Id
}