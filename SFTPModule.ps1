Add-Type -Path "$PSScriptRoot`\WinSCPnet.dll"

function Get-SFTPFingerprint($SFTPAddress, $Login, $Password){
    
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $SFTPAddress
        UserName = $Login
        Password = $Password
    }

    # Scan for the host key
    $session = New-Object WinSCP.Session

    try
    {
        $fingerprint = $session.ScanFingerprint($sessionOptions, "SHA-256")
    }
    finally
    {
        $session.Dispose()
    }
    
    $GLOBAL:SFTPFingerPrint = $fingerprint
}

function Download-SFTPFiles([string]$SFTPAddress, [string]$Login, [string]$Password, [string]$FilePath){
    
    if (-not $GLOBAL:SFTPFingerPrint){
        Get-SFTPKey -SFTPAddress $SFTPAddress -Login $Login -Password $Password
    }

    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $SFTPAddress
        UserName = $Login
        Password = $Password
        SshHostKeyFingerprint = $GLOBAL:SFTPFingerPrint
    }

    $session = New-Object WinSCP.Session

    try
    {
        $session.Open($sessionOptions)
        $GetFilesSessionData = $session.GetFiles("*", $FilePath)
    }
    finally
    {
        $session.Dispose()
    }

    if ($GetFilesSessionData.IsSuccess){
        return $true
    }
    else{
        if (Get-Command "Add-LogEntry" -ErrorAction SilentlyContinue -and ($GetFilesSessionData.Failures).Count -gt 0)
        {
            $errstr = "(!)"
            $GetFilesSessionData.Failures |% {
                if ($_){
                    $errstr += "$_; "
                }
            }
            
            Add-LogEntry $errstr
        }

        return $false
    }
}

function Upload-SFTPFile([string]$SFTPAddress, [string]$Login, [string]$Password, [string]$FilePath){
    
    if (-not $GLOBAL:SFTPFingerPrint){
        Get-SFTPKey -SFTPAddress $SFTPAddress -Login $Login -Password $Password
    }

    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $SFTPAddress
        UserName = $Login
        Password = $Password
        SshHostKeyFingerprint = $GLOBAL:SFTPFingerPrint
    }

    $session = New-Object WinSCP.Session

    try
    {
        $session.Open($sessionOptions)
        $PutFilesSessionData = $session.PutFiles($FilePath, "*", $false)
    }
    finally
    {
        $session.Dispose()
    }

    if ($PutFilesSessionData.IsSuccess){
        return $true
    }
    else{
        if (Get-Command "Add-LogEntry" -ErrorAction SilentlyContinue -and ($PutFilesSessionData.Failures).Count -gt 0)
        {
            $errstr = "(!)"
            $PutFilesSessionData.Failures |% {
                if ($_){
                    $errstr += "$_; "
                }
            }
            
            Add-LogEntry $errstr
        }

        return $false
    }
}

function Test-SFTPFileExists([string]$SFTPAddress, [string]$Login, [string]$Password, [string]$FileName){
    
    if (-not $GLOBAL:SFTPFingerPrint){
        Get-SFTPKey -SFTPAddress $SFTPAddress -Login $Login -Password $Password
    }

    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $SFTPAddress
        UserName = $Login
        Password = $Password
        SshHostKeyFingerprint = $GLOBAL:SFTPFingerPrint
    }

    $session = New-Object WinSCP.Session

    try
    {
        $session.Open($sessionOptions)
        $TestPathSessionData = $session.FileExists($FileName)
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }

    if ($TestPathSessionData){
        return $true
    }
    else{
        return $false
    }
}
