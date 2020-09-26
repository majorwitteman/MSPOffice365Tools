function Get-AzBlobMD5 {
    [cmdletbinding()]
    param(
        # File path, best to use the fully qualified path (C:\path\to.file) rather than relative (.\path\to.file)
        [Parameter(ValueFromPipeline=$true)]
        [string]
        $FilePath
    )

    begin {
        $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    }

    process {
        foreach ($file in $FilePath) {
            try {
                $fs = [System.IO.FileStream]::new($file,[System.IO.FileMode]::Open)
            }
            catch {
                throw ($error[0]).Exception.InnerException.Message
            }
            $hash = [System.Convert]::ToBase64String($md5.ComputeHash($fs))
            $fs.Close()

            [pscustomobject]@{
                File = $file
                Hash = $hash
            }
        }
    }
}
