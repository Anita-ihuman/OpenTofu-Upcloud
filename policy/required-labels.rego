 # Check labels exist
package main
import future.keywords.if
import future.keywords.contains

# Use a list (or bind from the set with [_])
required_tags := {"Environment", "Owner"}

deny[msg] if {
  input.resource_type in {"aws_instance", "aws_s3_bucket"}
  some tag in required_tags
  not tag in input.tags
  msg := sprintf("Server is missing required label: %s", [req])
}
