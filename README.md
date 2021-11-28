# PS-SFTPModule
PowerShell functions for operating with a SFTP server.


Requires WinSCPnet.dll which should be placed in the same directory.


Contains 4 functions:

Get-SFTPFingerprint($SFTPAddress, $Login, $Password)

Download-SFTPFiles($SFTPAddress, $Login, $Password, $FilePath)

Upload-SFTPFile($SFTPAddress, $Login, $Password, $FilePath)

Test-SFTPFileExists($SFTPAddress, $Login, $Password, $FileName)
