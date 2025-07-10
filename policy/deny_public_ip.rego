package terraform.gcp.deny_public_ip

import input as tfplan

deny[msg] {
    some i
    tfplan.resource_changes[i].type == "google_compute_instance"
    tfplan.resource_changes[i].change.after.network_interface[_].access_config
    msg := sprintf("No se permite crear instancias con IP publica: %v", [tfplan.resource_changes[i].address])
}