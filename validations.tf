resource "null_resource" "register_workload_identity" {
  provisioner "local-exec" {
    command    = "az feature register --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview "
    on_failure = fail
  }
}

resource "null_resource" "create_workload_identity_status" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    null_resource.register_workload_identity
  ]
  provisioner "local-exec" {
    command    = "az feature show --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview | jq -r .properties.state > status.txt"
    on_failure = fail
  }
}

resource "null_resource" "check_workload_identity_status" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    null_resource.create_workload_identity_status
  ]
  provisioner "local-exec" {
    command    = "if [ $(cat status.txt) = 'Registered' ]; then $(exit 0); else echo 'EnableWorkloadIdentityPreview not enabled'; $(exit 1); fi"
    on_failure = fail
  }
}
