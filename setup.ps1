# Setup get-node-ips.ps1
$GetNodeIps = @"
(multipass ls --format csv | ConvertFrom-Csv | where Name -like "*Node*").IPv4
"@
$GetNodeIps | Out-File get-node-ips.ps1 -Force

# Setup ssh-connection-to-all-nodes.ps
$SetupSSHConnection = @"
(multipass ls --format csv | ConvertFrom-Csv | where Name -like "*Node*").IPv4 | foreach {ssh ubuntu@`$_}
"@
$SetupSSHConnection | Out-File ssh-connection-to-all-nodes.ps1 -Force

# Setup cloud-init.yaml
$CloudInit = @"
#cloud-config
users:
  - name: ubuntu
    ssh_authorized_keys:
      - [SSHPUBKEYHERE]
runcmd:
  - git clone https://github.com/bluknght/u2004
  - cd /u2004 && bash install.sh
  - usermod -aG docker ubuntu
  - rm -rf /u2004
"@
$SSHPubKey = Get-Content ~/.ssh/id_rsa.pub
$CloudInit = $CloudInit.replace("[SSHPUBKEYHERE]","$SSHPubKey")
$CloudInit | Out-File cloud-init.yaml -Force

# Setup create-multipass-nodes.ps1
$CreateMultipassNodes = @"
`$Nodes = Read-Host "How many nodes do you want to create?"
for (`$Node = 1 ; `$Node -le `$Nodes ; `$Node++){multipass launch --name node`$Node --cloud-init cloud-init.yaml}
"@
$CreateMultipassNodes | Out-File create-multipass-nodes.ps1 -Force

# Setup delete-multipass-nodes.ps1
$DeleteNodes = @"
(multipass ls --format csv | ConvertFrom-Csv | where Name -like "*Node*")..Name | foreach {multipass delete `$_}
multipass purge
"@
$DeleteNodes | Out-File delete-multipass-nodes.ps1 -Force
