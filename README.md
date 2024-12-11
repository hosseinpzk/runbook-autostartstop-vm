# runbook-autostartstop-vm
Auto Start/Stop your vm in Azure

Create a runbook, write PowerShell script in it and assign it to your subscription.
Add schedule time and give it parameters to:
1- VM Name
2- Resource Group
3- action: Start or Stop
4- Time and Ruccuring 

Enable a system-assigned managed identity for your Automation Account:
Go to your Automation Account in the Azure portal.
Under Identity, enable the system-assigned identity.
Assign the required role to the managed identity:

Go to the resource (e.g., Resource Group) where you need permissions.
Assign the Contributor role to the Automation Account's managed identity.
