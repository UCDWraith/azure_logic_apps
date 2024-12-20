# Logic App: dev-logic-entra-guestuser-expiry

## Introduction

This logic app looks to automate the disabling of stale guest users in your Entra tenant.

- A grace period is granted for newly created accounts which have not been logged into.
- Accounts that have never been logged into beyond the grace period are disabled.
- Active (per the logic of the app) accounts are left alone
- Inactive accounts beyond the threshold are disabled.
- Inactive accounts within the threshold have their sessions revoked.
- Various arrays are generated to facilitate further analysis of potentially stale accounts or guest membership in groups that are not managed with an access review.

The template will deploy a **Consumption** based Logic App and it will create an associated 'System assigned Managed Identity'.

Out of the box the newly created managed identity will not have the required permissions to successfully run the logic app. I have included a PowerShell script which will assign the required permissions to the new managed identity within Microsoft Graph.

## Required Microsoft Graph API permissions

|API Permission|Allows the managed identity to:
|----|----
|"User.Read.All"|Read all users in your Entra tenant
|"AuditLog.Read.All"|Retrieve the sign in activity data from the Beta API
|"Group.Read.All"|Read group membership data
|"User.ReadWrite.all"|Modify the user accounts in your Entra tenant
|"User.EnableDisableAccount.All"|Disable user accounts in your Entra tenant
|"User.RevokeSessions.All"|Revoke all sessions belonging to a user

*The summary above only lists the API relevance to this logic app. Improperly assigning API permissions or failing to secure their use can have significant consequences for your environment.*

## Outline pseudoCode of logic app
A lookback period, currently set to 30 days, is set as a threshold value. Due to environment considerations guest users may be in some baseline groups 'corpGuestUsers' or 'guestsNoEmployeeId' for example that are used for tracking or Conditional Access evaluation. In the included logic these baseline groups grant no internal corporate access and as such, membership only in these groups indicates the guest user should be disabled.

The logic breaks down as follow:

- If the account is disabled:
  - Add details to array-disabledGuests [No further action required].

- If the account is enabled:
  - If signInActivity == NULL [The account has never been logged into]:
    - If the createdDateTime is less than lookbackPeriod days ago:
      - Add details to array-newAccount [No further action required].
    - If the createdDateTime is greater than lookbackPeriod days ago:
      - Add details to array-neverLoggedIn.
      - Disable the account.

  - If signInActivity != NULL
    - Get the list of groups the guest user is a member of:
      - For Each group the guest is a member of:
        - Add details to array-guestGroups.
        - Add details to array-groupAffiliations.
        - Set variables to test group membership conditions.

      - If the guest user is in additional groups:
        - Add details to array-otherGroups [No further action required].

      - If the guest user is only in the core groups:
        - A variable lastSignIn is set to either the lastSignInDateTime or lastNonInteractiveSignInDateTime.

        - If the guest has signed in within the lookbackPeriod:
          - Add details to array-recentLoginGuests.
          - Revoke all sessions on their user account.

        - If the guest has NOT signed in within the lookbackPeriod:
          - Add details to array-guestsToDisable
          - Disable the guest user account

- Remove duplicate groups from array-groupList
- Output the various array objects so they can be reviewed in the 'Run history' for the logic app.

## Logic App Structure

## Design consideration

- When guests users are granted access to your environment they often linger well after their work concludes. Teams, Sharepoint, PowerBI connections can often still successfully 'authenticate' nonInteractively in the background despite no longer having 'authorization' within the tenant. To combat these benign lingering connections the logic app when run will revokeSessions for a user forcing them to explicitly re-authenticate. At this point they will observe they still need access and make contact with a relevant corporate contact to request extended access. They may have mistakenly been removed automatically via the configured default action within an access review.

- If you are using Access Reviews in your environment the output of 'array-groupList' can be used to validate that each group is subject to an Access Review. I am finishing up an Automation Runbook which will match the groupId to an Access Review definition in your tenant if it exists. I will link that project here once complete.

## Deploy to Azure

Click the button below to deploy the Logic App to Azure.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FUCDWraith%2Fazure_logic_apps%2Fmain%2Fdev-logic-entra-guestuser-expiry%2Ftemplate.json)

The Logic App is deployed in a **DISABLED** state. When you have assigned the relevant API permissions 'Enable' the Logic App in the portal.

I have generalised the Object ID's of the generalised groups in the template:
- "11111111-1111-1111-1111-111111111111"
- "22222222-2222-2222-2222-222222222222"

These should be updated accordingly or the surrounding logic removed if it is not required.
