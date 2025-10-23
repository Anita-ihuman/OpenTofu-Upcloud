# Check VM not too big
package main
import future.keywords.if
import future.keywords.in
import future.keywords.contains

allowed_plans := {
  "1xCPU-1GB",
  "1xCPU-2GB",
  "2xCPU-4GB",
  "4xCPU-8GB",
}

deny[msg] if {
  some i
  r := input.resource_changes[i]
  r.type == "upcloud_server"
  r.change.actions[_] == "create"

  plan := r.change.after.plan
  not (plan in allowed_plans)

  msg := sprintf("VM plan '%s' exceeds maximum allowed size of 4xCPU-8GB", [plan])
}