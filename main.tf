/**
 * # AWS EKS Custom Kube Scheduler Terraform module
 *
 * A Terraform module to deploy a [Custom Kube Scheduler](https://kubernetes.io/docs/reference/scheduling/config/) on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-kube-scheduler/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-kube-scheduler/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-kube-scheduler/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-kube-scheduler/actions/workflows/pre-commit.yaml)
 */

locals {
  addon = {
    name      = "kube-scheduler"
    namespace = "kube-system"

    helm_chart_name    = "kubernetes-scheduler"
    helm_chart_version = var.helm_chart_version != null ? var.helm_chart_version : var.manifest_target_revision
    helm_repo_url      = var.helm_repo_url != null ? var.helm_repo_url : "https://github.com/lablabs/terraform-aws-eks-kube-scheduler"
    argo_enabled       = var.argo_enabled != null ? var.argo_enabled : true
    argo_source_type   = var.argo_source_type != null ? var.argo_source_type : "helm-directory"
    argo_source_path   = var.argo_source_path != null ? var.argo_source_path : var.manifest_target_path
    argo_helm_enabled  = var.argo_helm_enabled != null ? var.argo_helm_enabled : true
  }

  addon_irsa = {
    (local.addon.name) = {
    }
  }

  addon_values = yamlencode({
    nameOverride = local.addon.name
    config = {
      schedulerName = local.addon.name
    }
  })

  addon_depends_on = []
}
