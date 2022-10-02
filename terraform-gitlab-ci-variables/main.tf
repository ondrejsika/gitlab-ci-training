terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.18.0"
    }
  }
}

provider "gitlab" {
  token    = "YBNvsDxPyAPycqyX4KRN"
  base_url = "https://gitlab.sikademo.com"
}

locals {
  project_id = 3
  variables = {
    XXX_AAA = "111"
    XXX_BBB = "222"
  }
  protected_variables = {
    XXX_CCC = "333"
    XXX_DDD = "4444"
  }
}

resource "gitlab_project_variable" "variables" {
  for_each = local.variables
  project  = local.project_id
  key      = each.key
  value    = each.value
}

resource "gitlab_project_variable" "protected_variables" {
  for_each  = local.protected_variables
  project   = local.project_id
  key       = each.key
  value     = each.value
  protected = true
}
