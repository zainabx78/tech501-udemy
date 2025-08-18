output "jenkins_url" {
  value = "http://${google_compute_instance.jenkins-vm.network_interface[0].access_config[0].nat_ip}:8080"
}

output "kubernetes-ip" {
  value = "${google_compute_instance.k8s-vm.network_interface[0].access_config[0].nat_ip}"
}