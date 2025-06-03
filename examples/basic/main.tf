locals {
  kube_scheduler_helm = {
    name      = "custom-kube-scheduler"
    namespace = "kube-system"
    version   = "1.0.0"
    values = {
      image = {
        tag = "v1.30.13" # please review versions for kube-scheduler: https://github.com/kubernetes/kube-scheduler/tags?after=kubernetes-1.33.0
      }
      schedulerName = "custom-scheduler"
      replicaCount  = 2 # HA Setup
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
      serviceAccount = {
        create = true
        name   = "custom-kube-scheduler-sa"
      }
      # Config part is related to KubeSchedulerConfig values to create custom kube Scheduler
      config = {
        leaderElection = {
          leaderElect   = true
          leaseDuration = "15s"
          renewDeadline = "10s"
          retryPeriod   = "2s"
        }
        plugins = {
          queueSort = {
            enabled = ["PrioritySort"]
          }
          preFilter = {
            enabled  = ["NodeResourcesFit"]
            disabled = ["PodTopologySpread"]
          }
          filter = {
            enabled  = ["NodeResourcesFit", "PodTopologySpread"]
            disabled = []
          }
          score = {
            enabled  = ["NodeResourcesFit", "PodTopologySpread"]
            disabled = []
          }
        }
        pluginConfig = [
          {
            name = "NodeResourcesFit"
            args = {
              ignoredResourceGroups = ["example.com"]
              scoringStrategy = {
                type = "MostAllocated"
              }
            }
          }
        ]
      }
    }
  }
}

module "addon_installation_disabled" {
  source = "../../"

  enabled = false
}

module "addon_installation_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  values = yamlencode(local.kube_scheduler_helm.values)
}

# Please, see README.md and Argo Kubernetes deployment method for implications of using Kubernetes installation method
module "addon_installation_argo_kubernetes" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = false

  values = yamlencode(local.kube_scheduler_helm.values)

  argo_sync_policy = {
    automated   = {}
    syncOptions = ["CreateNamespace=true"]
  }
}

module "addon_installation_argo_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  values = yamlencode(local.kube_scheduler_helm.values)

  argo_sync_policy = {
    automated   = {}
    syncOptions = ["CreateNamespace=true"]
  }
}
