# Docker Desktop integration

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create a Docker network for the application
resource "docker_network" "app_network" {
  name = "app-network"
}

# Create a Docker volume for persistent storage
resource "docker_volume" "app_volume" {
  name = "app-volume"
}

# Create a Docker container for testing
resource "docker_container" "test_container" {
  name  = "test-container"
  image = docker_image.test_image.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  volumes {
    volume_name    = docker_volume.app_volume.name
    container_path = "/data"
  }

  ports {
    internal = 80
    external = 8080
  }
}

# Pull a test image
resource "docker_image" "test_image" {
  name = "nginx:latest"
} 