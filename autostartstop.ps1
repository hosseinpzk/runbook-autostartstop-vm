Param(
    # Parameters provided by the user to specify VM and action.
    [string]$VmName,
    [string]$ResourceGroupName,
    [ValidateSet("Start", "Stop")]
    [string]$VmAction
)

# Authenticate using Managed Identity
try {
    Write-Output "Logging in to Azure with Managed Identity..."
    Connect-AzAccount -Identity > $null
    Write-Output "✔️ Successfully authenticated."
} catch {
    Write-Error "❌ Failed to authenticate with Managed Identity: $_"
    throw $_
}

# Get current date and time in the desired timezone
$UTCTime = (Get-Date).ToUniversalTime()
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById("Central Europe Standard Time")
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
$day = $LocalTime.DayOfWeek

# Validate whether this is running on a weekend
if ($day -eq 'Saturday' -or $day -eq 'Sunday') {
    Write-Output "It is $($day). Cannot use a runbook to start VMs on a weekend."
    Exit
} else {
    Write-Output "✔️ It is $($day). Continuing..."
}

# Perform the requested action on the VM(s)
if ($VmAction -eq "Start") {
    if ($VmName -eq "*") {
        # Start all VMs in the specified resource group
        $vms = Get-AzVM -ResourceGroupName $ResourceGroupName | Select-Object -ExpandProperty Name
        foreach ($vm in $vms) {
            Write-Output "🔌 Starting $vm in resource group $ResourceGroupName..."
            Start-AzVM -Name $vm -ResourceGroupName $ResourceGroupName > $null
            $state = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vm -Status).Statuses[1].Code
            if ($state -eq "PowerState/running") {
                Write-Output "✔️ Successfully started $vm. It is now running."
            } else {
                Write-Output "❌ Failed to start $vm. Current status: $state."
            }
        }
    } else {
        # Start a specific VM
        Write-Output "🔌 Starting $VmName in resource group $ResourceGroupName..."
        Start-AzVM -Name $VmName -ResourceGroupName $ResourceGroupName > $null
        $state = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status).Statuses[1].Code
        if ($state -eq "PowerState/running") {
            Write-Output "✔️ Successfully started $VmName. It is now running."
        } else {
            Write-Output "❌ Failed to start $VmName. Current status: $state."
        }
    }
} elseif ($VmAction -eq "Stop") {
    if ($VmName -eq "*") {
        # Stop all VMs in the specified resource group
        $vms = Get-AzVM -ResourceGroupName $ResourceGroupName | Select-Object -ExpandProperty Name
        foreach ($vm in $vms) {
            Write-Output "🔌 Stopping $vm in resource group $ResourceGroupName..."
            Stop-AzVM -Name $vm -ResourceGroupName $ResourceGroupName -Force > $null
            $state = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vm -Status).Statuses[1].Code
            if ($state -eq "PowerState/deallocated") {
                Write-Output "✔️ Successfully stopped $vm. It is now deallocated."
            } else {
                Write-Output "❌ Failed to stop $vm. Current status: $state."
            }
        }
    } else {
        # Stop a specific VM
        Write-Output "🔌 Stopping $VmName in resource group $ResourceGroupName..."
        Stop-AzVM -Name $VmName -ResourceGroupName $ResourceGroupName -Force > $null
        $state = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status).Statuses[1].Code
        if ($state -eq "PowerState/deallocated") {
            Write-Output "✔️ Successfully stopped $VmName. It is now deallocated."
        } else {
            Write-Output "❌ Failed to stop $VmName. Current status: $state."
        }
    }
} else {
    Write-Error "❌ Invalid action specified. Use 'Start' or 'Stop'."
}
