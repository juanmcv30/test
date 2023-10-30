resource "random_password" "password" {
  length           = var.password_length
  special          = false
  override_special = "!@#%^"
}

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

  metadata_startup_script = <<-EOT
    <powershell>
    # Create a new user
    $secureUserPassword = ConvertTo-SecureString ${random_password.password.result} -AsPlainText -Force
    New-LocalUser -Name ${var.admin_username} -Password $secureUserPassword -FullName "User"
    
    # Add the new user to the Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member ${var.admin_username}

    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install -y office nodejs.install openjdk8 vscode git
    Restart-Computer
    </powershell>
  EOT

  metadata = {
    adminUsername = var.admin_username
    adminPassword = random_password.password.result
  }
}