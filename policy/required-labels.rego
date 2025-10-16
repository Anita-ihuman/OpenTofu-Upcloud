 # Check labels exist
package main
import future.keywords.if
import future.keywords.contains

# Use a list (or bind from the set with [_])
required_labels := ["environment", "managed_by"]

deny contains msg if {
  some i
  r := input.resource_changes[i]
  r.type == "upcloud_server"
  r.change.actions[_] == "create"

  labels := r.change.after.labels

  req := required_labels[_]

  not labels[req]

  msg := sprintf("Server is missing required label: %s", [req])
}

