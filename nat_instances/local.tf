locals {
  asg_hook_name = "update_route_tables"

  lifecycle_hooks = {
    "${local.asg_hook_name}_launch" : {
      timeout_in_seconds    = 30
      launch_lifecycle      = true
      notification_metadata = null
    }
    "${local.asg_hook_name}_terminate" : {
      timeout_in_seconds    = 30
      launch_lifecycle      = false
      notification_metadata = null
    }
  }
}
