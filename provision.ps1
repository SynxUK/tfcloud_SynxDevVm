Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Invoke-Expression -Command 'choco install -y powershell-core git terraform vscode googlechrome'
