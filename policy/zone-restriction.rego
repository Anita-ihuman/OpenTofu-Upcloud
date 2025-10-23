# Check zone is allowed
package main
import future.keywords.if
import future.keywords.in
import future.keywords.contains

allowed_zones := {
  "us-nyc1",
  "us-chi1",
  "us-sjo1",
  "de-fra1",
}

deny[msg] if {
  some i
  r := input.resource_changes[i]
  r.type == "upcloud_server"
  r.change.actions[_] == "create"

  zone := r.change.after.zone
  not (zone in allowed_zones)

  msg := sprintf("Server is in unauthorized zone: %s", [zone])
}

