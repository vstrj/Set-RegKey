function Set-RegKey {
    <#
    .SYNOPSIS
        Writes or removes a Registry Key Value and data.
    .DESCRIPTION
        Creates a Registry Key under the specified path with a Registry Value and data. 
        If the Registry Key does not exist, it creates it. If the Remove switch is used,
        it removes the specified Registry Value but not the key.
        
    .PARAMETER RegKey
        The registry key that should be created or modified.
    .PARAMETER RegValue
        The registry value that should be created or removed.
    .PARAMETER RegData
        The data that should be in the registry value.
    .PARAMETER RegType
        The type of the registry value.
    .PARAMETER Remove
        Switch to indicate that the registry value should be removed.
    .NOTES
    Version:        1.2
    Author:         victor.storsjo@crayon.com
    Creation Date:  2024/08/07
    Purpose/Change: Initial script development, improved by ChatGPT
    
    .EXAMPLE
    Set-RegKey -RegKey "HKLM:\SOFTWARE\VSTRJ" -RegValue "vstrj_value" -RegData "00000001" -RegType "DWord"
    Set-RegKey -RegKey "HKLM:\SOFTWARE\VSTRJ" -RegValue "vstrj_value" -Remove
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $RegKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $RegValue,

        [Parameter(Mandatory = $false)]
        [String] $RegData,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "Qword")]
        [String] $RegType = "DWord",

        [Parameter(Mandatory = $false)]
        [Switch] $Remove
    )
  
    process {
        try {
            # Ensure the registry key exists
            if (-not (Test-Path $RegKey)) {
                if (-not $Remove) {
                    New-Item -Path $RegKey -Force | Out-Null
                } else {
                    Write-Host "Registry key does not exist, cannot remove value."
                    return
                }
            }

            if ($Remove) {
                # Remove the specified registry value
                if (Test-Path "$RegKey\$RegValue") {
                    Remove-ItemProperty -Path $RegKey -Name $RegValue -Force
                    Write-Host "Removed $RegValue value from registry"
                } else {
                    Write-Host "Registry value $RegValue does not exist."
                }
            } else {
                # Set the registry value
                New-ItemProperty -Path $RegKey -Name $RegValue -Value $RegData -PropertyType $RegType -Force | Out-Null
                Write-Host "Changed $RegValue value in registry to $RegData"
            }
        }
        catch {
            Write-Host "Could not change $RegValue value in registry"
        }
    }
}
