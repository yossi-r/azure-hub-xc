locals {
  hipster_manifest_content = templatefile(format("%s/manifest/hipster.tpl", path.module), {
    frontend_domain_url = format("https://%s.%s", var.hipster_app_domain, var.dnsdelegatedzone) 
  })
}

resource "local_file" "hipster_manifest" {
  content  = local.hipster_manifest_content
  filename = format("%s/_output/hipster-adn.yaml", path.root)
}

resource "null_resource" "create_namespace" {
  depends_on = [local_file.kube_config, local_file.hipster_manifest]
#  triggers = {
#    manifest_sha1 = sha1(local.hipster_manifest_content)
#  }
  provisioner "local-exec" {
    command = "kubectl create namespace ${var.namespace}"
    environment = {
      KUBECONFIG = format("%s/aks-cluster-config", path.root)
    }
  }
}

resource "null_resource" "apply_manifest" {
  depends_on = [local_file.kube_config, local_file.hipster_manifest, null_resource.create_namespace]
#  triggers = {
#    manifest_sha1 = sha1(local.hipster_manifest_content)
#  }
  provisioner "local-exec" {
    command = "kubectl apply -f _output/hipster-adn.yaml -n ${var.namespace}"
    environment = {
      KUBECONFIG = format("%s/aks-cluster-config", path.root)
    }
  }
}