resource "scaleway_ip" "k8s_node_ip" {
  count = "${var.nodes}"
}

resource "scaleway_server" "k8s_node" {
  count          = "${var.nodes}"
  name           = "${terraform.workspace}-node-${count.index + 1}"
  image          = "${data.scaleway_image.nodes_os_image.id}"
  type           = "${var.server_type_node}"
  public_ip      = "${element(scaleway_ip.k8s_node_ip.*.ip, count.index)}"
  security_group = "${scaleway_security_group.node_security_group.id}"

   # volume {
   #   size_in_gb = 10
   #   type       = "l_ssd"
   # }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.private_key)}"
  }
  provisioner "file" {
    source      = "scripts/docker-install.sh"
    destination = "/tmp/docker-install.sh"
  }
  provisioner "file" {
    source      = "scripts/kubeadm-install.sh"
    destination = "/tmp/kubeadm-install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/docker-install.sh && /tmp/docker-install.sh ${var.docker_version}",
      "chmod +x /tmp/kubeadm-install.sh && /tmp/kubeadm-install.sh ${var.k8s_version}",
      "${data.external.kubeadm_join.result.command}",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "kubectl get pods --all-namespaces",
    ]

    on_failure = "continue"

    connection {
      type = "ssh"
      user = "root"
      host = "${scaleway_ip.k8s_master_ip.0.ip}"
    }
  }
}

# resource "scaleway_volume" "k8s_node" {
#   name       = "k8s_node"
#   size_in_gb = 40
#   type       = "l_ssd"
# }
#
# resource "scaleway_volume_attachment" "k8s_node" {
#   server = "${scaleway_server.k8s_node.id}"
#   volume = "${scaleway_volume.k8s_node.id}"
# }
