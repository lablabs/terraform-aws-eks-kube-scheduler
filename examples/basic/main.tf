locals {
  kube_scheduler_helm = {
    name      = "custom-kube-scheduler"
    namespace = "kube-system"
    version   = "1.0.0"
    values = {
      image = {
        tag = "v1.30.13" # please review versions for kube-scheduler: https://github.com/kubernetes/kube-scheduler/tags?after=kubernetes-1.33.0
      }
      replicaCount = 2 # HA Setup, it enables by default --leader-elect=true
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
      podLabels = {
        app = "KubeSchedulerPod"
      }
      securityContext = {
        runAsRoot = true
      }
      serviceAccount = {
        create = true
        name   = "custom-kube-scheduler-sa"
      }
      # Config part is related to KubeSchedulerConfig values to create custom kube Scheduler
      config = {
        create              = true
        schedulerName       = "custom-kube-scheduler"
        kubeSchedulerConfig = <<-EOT
          apiVersion: kubescheduler.config.k8s.io/v1
          kind: KubeSchedulerConfiguration
          leaderElection:
            leaderElect: false
            resourceName: custom-scheduler
            resourceNamespace: kube-system
          profiles:
          - schedulerName: custom-scheduler
            pluginConfig:
            - name: NodeResourcesFit
              args:
                scoringStrategy:
                  resources:
                  - name: cpu
                    weight: 1
                  - name: memory
                    weight: 1
                  type: MostAllocated
            plugins:
              score:
                enabled:
                - name: NodeResourcesFit
                  weight: 1
            leaderElect: false
            pluginApiVersion: kubescheduler.config.k8s.io/v1
            pluginConfig:
            - args:
                scoringStrategy:
                  resources:
                  - name: cpu
                    weight: 1
                  - name: memory
                    weight: 1
                  type: MostAllocated
              name: NodeResourcesFit
        EOT
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
