######################################################################################
# Create a new instance of the jumpbox                                               #
#     This script creates a single virtual machine and sets it up for PCF deployment #
######################################################################################
resource "google_compute_instance" "jumpbox" {
  name         = "${var.bastion_name}"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size = "200"
    }
  }

  network_interface {
    network = "default"
    access_config {} // Ephemeral IP
  }

  # This is where we upload the files necessary for preparing the jumpbox
  provisioner "file" {
    source      = "./config/init.sh"
    destination = "/home/ubuntu/init.sh"

    connection {
            type = "ssh"
            user = "ubuntu"
            private_key = "${file("~/.ssh/google_compute_engine")}"
    }
  }

  # Last step: we trigger the download and installation of all tools
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/init.sh",
      ". /home/ubuntu/init.sh",
    ]

    connection {
            type = "ssh"
            user = "ubuntu"
            private_key = "${file("~/.ssh/google_compute_engine")}"
    }
  }
}
