resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = "n1-standard-2"
  zone         = var.zone
  tags         = ["http-server"]
  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
    }
  }

  network_interface {
    network = google_compute_network.network.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {
      // This creates an external IP address for the instance
    }
  }

  metadata = {
    windows-startup-script-ps1 = <<-EOF
  add-type -AssemblyName System.Web
  Add-WindowsCapability -Online -Name OpenSSH.Server
  ssh-agent.exe
  # Define the path to the desktop folder
  $desktopPath = [Environment]::GetFolderPath("Desktop")

  
  # Array of usernames to add to the admin group
  $emails = @("Fabio.rincon@arroyoconsulting.net", "andres.zapata@arroyoconsulting.net", "carlos.albarran@arroyoconsulting.net")  # Add your list of usernames here
  
  # Loop through the usernames and add them to the admin group
  foreach ($email in $emails) {
      Write-Host $emails
      
      $password = [guid]::NewGuid().ToString() | Get-Random

      $secureString = ConvertTo-SecureString $password -AsPlainText -Force
      $quotedSecureString = $secureString 

      $name = $email.Split("@")[0]
      
      New-LocalUser -Name $name -Password $quotedSecureString -Description "SSH User: $email"
      New-Item -Path "C:\Users\$name\.ssh" -ItemType Directory
  
      # Add the user to the admin group
      Add-LocalGroupMember -Group "Administrators" -Member $name

      Start-Process ssh-keygen -b 4096 -f C:\Users\$name\.ssh\$name -C $email -N $passphrase '' -Wait

      $authorizedKeysFile = "C:\Users\$name\.ssh\authorized_keys"
      Add-Content -Path $authorizedKeysFile -Value (Get-Content "C:\Users\$name\.ssh\key.pub")

     
  }
  

  # Install Chocolatey
  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  
  # Install Office, Node.js, Java, Visual Studio Code, and GIT
  choco install nodejs openjdk microsoft-office-deployment javaruntime vscode git -y
  
  # Set Environment Variables for Java
  #$javaPath = (Get-Command java).Source
  #[Environment]::SetEnvironmentVariable('JAVA_HOME', $javaPath, [System.EnvironmentVariableTarget]::Machine)
  #[Environment]::SetEnvironmentVariable('Path', "$($env:Path);$javaPath\bin", [System.EnvironmentVariableTarget]::Machine)
  
 
  # Verify installations
  Write-Host "Chocolatey, Office, Node.js, Java, Visual Studio Code, and GIT have been installed."
  

  EOF
  }


}