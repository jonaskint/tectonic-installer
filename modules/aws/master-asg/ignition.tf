data "ignition_config" "main" {
  files = [
    "${data.ignition_file.detect_master.id}",
    "${data.ignition_file.init_assets.id}",
    "${data.ignition_file.rm_assets.id}",
    "${var.ign_installer_kubelet_env_id}",
    "${var.ign_installer_runtime_mappings_id}",
    "${var.ign_max_user_watches_id}",
    "${var.ign_s3_puller_id}",
  ]

  systemd = ["${compact(list(
    var.ign_docker_dropin_id,
    var.ign_locksmithd_service_id,
    var.ign_kubelet_service_id,
    var.ign_k8s_node_bootstrap_service_id,
    var.ign_init_assets_service_id,
    var.ign_rm_assets_service_id,
    var.ign_bootkube_service_id,
    var.ign_tectonic_service_id,
    var.ign_bootkube_path_unit_id,
    var.ign_tectonic_path_unit_id,
    var.ign_rm_assets_path_unit_id,
   ))}"]
}

data "template_file" "detect_master" {
  template = "${file("${path.module}/resources/detect-master.sh")}"

  vars {
    load_balancer_name = "${format("%s-%s", var.cluster_name, var.private_endpoints ? "int" : "ext")}"
  }
}

data "ignition_file" "detect_master" {
  filesystem = "root"
  path       = "/opt/detect-master.sh"
  mode       = 0755

  content {
    content = "${data.template_file.detect_master.rendered}"
  }
}

data "template_file" "init_assets" {
  template = "${file("${path.module}/resources/init-assets.sh")}"

  vars {
    cluster_name       = "${var.cluster_name}"
    awscli_image       = "${var.container_images["awscli"]}"
    assets_s3_location = "${var.assets_s3_location}"
  }
}

data "ignition_file" "init_assets" {
  filesystem = "root"
  path       = "/opt/init-assets.sh"
  mode       = 0755

  content {
    content = "${data.template_file.init_assets.rendered}"
  }
}

data "template_file" "rm_assets" {
  template = "${file("${path.module}/resources/rm-assets.sh")}"

  vars {
    cluster_name       = "${var.cluster_name}"
    awscli_image       = "${var.container_images["awscli"]}"
    assets_s3_location = "${var.assets_s3_location}"
  }
}

data "ignition_file" "rm_assets" {
  filesystem = "root"
  path       = "/opt/rm-assets.sh"
  mode       = 0755

  content {
    content = "${data.template_file.rm_assets.rendered}"
  }
}
