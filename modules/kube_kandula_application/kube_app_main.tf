locals {
  k8s_namespace               = "kandula"
  k8s_service_account_name    = "${local.k8s_namespace}-service-account"
  app_name_label              = "kandula"
  kandula_docker_image_prefic = "galitu/kandula-repo:kandula-final-prj"
  kandula_port                = "5000"
  kandula_secret              = "kandula-secrets"
  kandula_task                = "Final-Project"
}

data "kubernetes_namespace_v1" "kandula_app_namespace" {
  metadata {
    name = local.k8s_namespace
  }
}

# Kandula secret
resource "kubernetes_secret" "kandula_app_secrets" {
  metadata {
    namespace = data.kubernetes_namespace_v1.kandula_app_namespace.metadata[0].name
    name      = local.kandula_secret
  }

  data = {
    "AWS_ACCESS_KEY_ID"     = var.aws_access_key_id,
    "AWS_SECRET_ACCESS_KEY" = var.aws_sercret_access_key,
    "AWS_DEFAULT_REGION"    = var.aws_default_region,
    "USER_NAME"             = var.login_user_name,
    "USER_PASSWORD"         = var.login_password,
    "TERMINATION_DRY_RUN"   = var.termination_dry_run
  }
  # Opaque: arbitrary user-defined data
  type = "Opaque"
}

resource "kubernetes_deployment_v1" "kandula_app_deploy" {
  metadata {
    namespace = data.kubernetes_namespace_v1.kandula_app_namespace.metadata[0].name
    name      = "deployment-${local.app_name_label}-app"
    labels = {
      version = var.kandula_image_version
      task    = local.kandula_task
      app     = local.app_name_label
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = local.app_name_label
      }
    }

    min_ready_seconds = 10
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 1
        max_surge       = 1
      }
    }


    template {
      metadata {
        labels = {
          app     = local.app_name_label
          version = var.kandula_image_version
        }
        annotations = {
          "consul.hashicorp.com/connect-inject"       = "true"
          "consul.hashicorp.com/transparent-proxy"    = "false"
          "consul.hashicorp.com/connect-service"      = "${local.app_name_label}"
          "consul.hashicorp.com/connect-service-port" = "5000"
          "consul.hashicorp.com/service-tags"         = "kandula,fprj"
          "consul.hashicorp.com/service-name"         = "kandula-application"
          "consul.hashicorp.com/service-meta-owner"   = "Galit Udovik"
          "consul.hashicorp.com/service-meta-purpose" = "Kandula final project"
          "prometheus.io/scrape"                      = "true"
          "prometheus.io/port"                        = "5000"
          "prometheus.io/path"                        = "/metrics"
        }
      }

      spec {
        container {
          image = "${local.kandula_docker_image_prefic}-${var.kandula_image_version}"
          name  = local.app_name_label
          env {
            name  = "FLASK_ENV"
            value = "development"
          }
          env_from {
            secret_ref {
              name = local.kandula_secret
            }
          }
          port {
            container_port = local.kandula_port
            name           = "http"
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/login"
              port = local.kandula_port
            }

            initial_delay_seconds = 5
            timeout_seconds       = 1
            period_seconds        = 10
            failure_threshold     = 3
          }
        }
        service_account_name = "kandula-account-mgr"
        # service_account_name = "${local.k8s_service_account_name}"
      }
    }
  }
}

# Kandula ClusterIP service
resource "kubernetes_service_v1" "kandula_svc" {
  metadata {
    namespace = data.kubernetes_namespace_v1.kandula_app_namespace.metadata[0].name
    name      = "${local.app_name_label}-cluster-ip"
    annotations = {
      "consul.hashicorp.com/service-name"         = "kandula-application"
      "consul.hashicorp.com/service-port"         = "http"
      "consul.hashicorp.com/service-tags"         = "kandula,fprj"
      "consul.hashicorp.com/service-meta-owner"   = "Galit Udovik"
      "consul.hashicorp.com/service-meta-purpose" = "Kandula final project"
      "consul.hashicorp.com/connect-inject"       = "true"
      "consul.hashicorp.com/transparent-proxy"    = "false"
      "consul.hashicorp.com/connect-service"      = "${local.app_name_label}"
      "consul.hashicorp.com/connect-service-port" = "5000"
      "prometheus.io/scrape"                      = "true"
      "prometheus.io/port"                        = "5000"
    }
    labels = {
      version = var.kandula_image_version
      task    = local.kandula_task
      app     = local.app_name_label
    }
  }
  spec {
    selector = {
      app = local.app_name_label
    }
    /*session_affinity = "ClientIP"*/
    port {
      name        = "http"
      port        = 80
      target_port = local.kandula_port
    }

    type = "ClusterIP"
  }
}

data "aws_acm_certificate" "compoze_acm" {
  domain   = "*.galitu.site"
  statuses = ["ISSUED"]
}

locals {
  ingress_rules = [
    {
      path = "/",
      name = kubernetes_service_v1.kandula_svc.metadata[0].name,
      port = 80
    }
    /*
    ,
    {
      path = "/",
      name = "ssl-redirect",
      port = "use-annotation"
    }
    */
  ]
}

resource "kubernetes_ingress" "kandula_ingress" {
  metadata {
    name      = "${local.app_name_label}-ingress"
    namespace = data.kubernetes_namespace_v1.kandula_app_namespace.metadata.0.name
    labels = {
      version = var.kandula_image_version
      task    = local.kandula_task
      app     = local.app_name_label
    }
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/group.name"           = "kandula"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-port"     = "5000"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-policy" : "ELBSecurityPolicy-TLS-1-2-2017-01"
      #"alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTPS\":443, \"HTTP\":80}]"
      #"alb.ingress.kubernetes.io/actions.ssl-redirect"     = "{\"Type\": \"redirect\", \"RedirectConfig\":{ \"Protocol\": \"HTTPS\", \"Port\": 443, \"StatusCode\": \"HTTP_301\"}}"
      "alb.ingress.kubernetes.io/certificate-arn"          = data.aws_acm_certificate.compoze_acm.arn
      "alb.ingress.kubernetes.io/tags"                     = "Owner=Galit Udovik,Task=Kandula,App_name=FPrj,CreatedBy=IngressYaml"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=4000,routing.http2.enabled=false"
      "alb.ingress.kubernetes.io/target-group-attributes"  = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=86400"
      "alb.ingress.kubernetes.io/load-balancer-name"       = "kubernetes-alb"
      "external-dns.alpha.kubernetes.io/hostname"          = "kandula.galitu.site"

      ### kubernetes.io/tls-acme" = "true"
    }
  }
  spec {
    backend {
      service_name = kubernetes_service_v1.kandula_svc.metadata[0].name
      service_port = 80
    }
    rule {
      host = "kandula.galitu.site"
      http {
        dynamic "path" {
          for_each = local.ingress_rules
          content {
            backend {
              service_name = path.value.name
              service_port = path.value.port
            }
            path = path.value.path
          }
        }
      }
    }
  }
  #######   ### tls {
  #######   ###     secret_name = "tls-secret"
  #######   ###  }

  wait_for_load_balancer = true
}


data "aws_route53_zone" "hosted_zone_53" {
  name         = var.route53_host_zone_name
  private_zone = false
}

resource "aws_route53_record" "kandula" {
  zone_id = data.aws_route53_zone.hosted_zone_53.zone_id
  name    = "kandula"
  type    = "CNAME"
  ttl     = "300"
  records = [kubernetes_ingress.kandula_ingress.status.0.load_balancer.0.ingress.0.hostname]
}

###############################################
###### Monitoring applications
resource "time_sleep" "wait_60_seconds" {
  depends_on = [aws_route53_record.kandula]

  create_duration = "60s"
}

resource "null_resource" "update_eks_local_config" {
  depends_on = [time_sleep.wait_60_seconds]
  provisioner "local-exec" {
    command = "aws eks --region=eu-central-1 update-kubeconfig --name  kandula-prj-kubeg --region ${var.aws_default_region} --name ${var.cluster_name}"
  }
}

resource "null_resource" "delete_monitoring" {
  depends_on = [null_resource.update_eks_local_config]

  # Uninstall prometheus
  provisioner "local-exec" {
    command    = "helm uninstall prometheus --namespace monitoring"
    on_failure = continue
  }
  provisioner "local-exec" {
    command    = "kubectl delete namespace monitoring"
    on_failure = continue
  }
  # Uninstall grafana
  provisioner "local-exec" {
    command    = "helm uninstall grafana --namespace grafana"
    on_failure = continue
  }
  provisioner "local-exec" {
    command    = "kubectl delete namespace grafana"
    on_failure = continue
  }
  # Uninstall consul
  provisioner "local-exec" {
    command    = "helm uninstall consul --namespace consul"
    on_failure = continue
  }
  provisioner "local-exec" {
    command    = "kubectl delete namespace consul"
    on_failure = continue
  }
}


#### resource "null_resource" "add_update_prometheus_repos" {
####   depends_on = [null_resource.delete_monitoring]
####   # Update all repos
####   provisioner "local-exec" {
####     command = "helm repo add prometheus-community https://prometheus-community.github.io/#### helm-charts"
####   }
#### }
#### resource "null_resource" "add_update_grafana_repos" {
####   depends_on = [null_resource.add_update_prometheus_repos]
####
####   provisioner "local-exec" {
####     command = "helm repo add grafana https://grafana.github.io/helm-charts"
####   }
#### }
#### resource "null_resource" "add_update_consul_repos" {
####   depends_on = [null_resource.add_update_grafana_repos]
####
####   provisioner "local-exec" {
####     command = "helm repo add hashicorp https://helm.releases.hashicorp.com"
####   }
#### }
#### resource "null_resource" "add_update_all_repos" {
####   depends_on = [null_resource.add_update_consul_repos]
####
####   provisioner "local-exec" {
####     command = "helm repo update"
####   }
#### }


resource "null_resource" "install_prometheus" {
  #depends_on = [null_resource.add_update_all_repos]
  depends_on = [null_resource.delete_monitoring]
  # Install all monotoring resources
  provisioner "local-exec" {
    command = "helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace --set alertmanager.persistentVolume.storageClass='gp2' --set server.persistentVolume.storageClass='gp2' --set-file extraScrapeConfigs=${path.module}/monitoring_values/extra_prom_values.yaml"
    # --values  ${path.module}/monitoring_values/prometheus_values.yaml"
  }
}

locals {
  ingress_prometheus_rules = [
    {
      path = "/",
      name = "prometheus-server",
      port = 80
    }
    /*
    ,
    {
      path = "/",
      name = "ssl-redirect",
      port = "use-annotation"
    }
    */
  ]
}
resource "kubernetes_ingress" "prometheus_ingress" {
  depends_on = [null_resource.install_prometheus]
  metadata {
    name      = "prometheus-ingress"
    namespace = "monitoring"
    labels = {
      task = local.kandula_task
      app  = "prometheus"
    }
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/group.name"           = "kandula"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/graph"
      "alb.ingress.kubernetes.io/healthcheck-port"     = "9090"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-policy" : "ELBSecurityPolicy-TLS-1-2-2017-01"
      #"alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTPS\":443, \"HTTP\":80}]"
      #"alb.ingress.kubernetes.io/actions.ssl-redirect"     = "{\"Type\": \"redirect\", \"RedirectConfig\":{ \"Protocol\": \"HTTPS\", \"Port\": 443, \"StatusCode\": \"HTTP_301\"}}"
      "alb.ingress.kubernetes.io/certificate-arn"          = data.aws_acm_certificate.compoze_acm.arn
      "alb.ingress.kubernetes.io/tags"                     = "Owner=Galit Udovik,Task=Kandula,App_name=FPrj,CreatedBy=IngressYaml,Purpose=Prometheus"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=4000,routing.http2.enabled=false"
      "alb.ingress.kubernetes.io/target-group-attributes"  = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=86400"
      "alb.ingress.kubernetes.io/load-balancer-name"       = "kubernetes-alb"
      "external-dns.alpha.kubernetes.io/hostname"          = "prometheus.galitu.site"
      ### kubernetes.io/tls-acme" = "true"
    }
  }
  spec {
    backend {
      service_name = "prometheus-server"
      service_port = 80
    }
    rule {
      host = "prometheus.galitu.site"
      http {
        dynamic "path" {
          for_each = local.ingress_prometheus_rules
          content {
            backend {
              service_name = path.value.name
              service_port = path.value.port
            }
            path = path.value.path
          }
        }
      }
    }
  }
  #######   ### tls {
  #######   ###     secret_name = "tls-secret"
  #######   ###  }

  wait_for_load_balancer = true
}

resource "aws_route53_record" "prometheus_record_53" {
  zone_id = data.aws_route53_zone.hosted_zone_53.zone_id
  name    = "prometheus"
  type    = "CNAME"
  ttl     = "300"
  records = [kubernetes_ingress.prometheus_ingress.status.0.load_balancer.0.ingress.0.hostname]
}

resource "null_resource" "update_grafana_values" {
  depends_on = [null_resource.install_consul]
  provisioner "local-exec" {
    command = "export KANDULA_DASHBOARD=`cat ${path.module}/monitoring_values/Kandula-dashboard.json`; export JENKINS_DASHBOARD=`cat ${path.module}/monitoring_values/Jenkins-Performance-Health-Overview.json`; envsubst < ${path.module}/monitoring_values/grafana_values.tmpl > ${path.module}/monitoring_values/grafana_values_kandula.yaml ;"
  }
}

resource "null_resource" "install_grafana" {
  depends_on = [null_resource.install_prometheus]
  provisioner "local-exec" {
    command = "helm install grafana grafana/grafana --namespace grafana --create-namespace --set persistence.storageClassName='gp2' --set persistence.enabled=true --set adminPassword='Galitu' --values ${path.module}/monitoring_values/grafana_values_kandula.yaml"
  }
}

locals {
  ingress_grafana_rules = [
    {
      path = "/",
      name = "grafana",
      port = 80
    }
    /*
    ,
    {
      path = "/",
      name = "ssl-redirect",
      port = "use-annotation"
    }
    */
  ]
}
resource "kubernetes_ingress" "grafana_ingress" {
  depends_on = [null_resource.install_grafana]
  metadata {
    name      = "grafana-ingress"
    namespace = "grafana"
    labels = {
      task = local.kandula_task
      app  = "grafana"
    }
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/group.name"           = "kandula"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-port"     = "3000"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-policy" : "ELBSecurityPolicy-TLS-1-2-2017-01"
      #"alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTPS\":443, \"HTTP\":80}]"
      #"alb.ingress.kubernetes.io/actions.ssl-redirect"     = "{\"Type\": \"redirect\", \"RedirectConfig\":{ \"Protocol\": \"HTTPS\", \"Port\": 443, \"StatusCode\": \"HTTP_301\"}}"
      "alb.ingress.kubernetes.io/certificate-arn"          = data.aws_acm_certificate.compoze_acm.arn
      "alb.ingress.kubernetes.io/tags"                     = "Owner=Galit Udovik,Task=Kandula,App_name=FPrj,CreatedBy=IngressYaml,Purpose=Grafana"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=4000,routing.http2.enabled=false"
      "alb.ingress.kubernetes.io/target-group-attributes"  = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=86400"
      "alb.ingress.kubernetes.io/load-balancer-name"       = "kubernetes-alb"
      "external-dns.alpha.kubernetes.io/hostname"          = "grafana.galitu.site"
      ### kubernetes.io/tls-acme" = "true"
    }
  }
  spec {
    backend {
      service_name = "grafana"
      service_port = 80
    }
    rule {
      host = "grafana.galitu.site"
      http {
        dynamic "path" {
          for_each = local.ingress_grafana_rules
          content {
            backend {
              service_name = path.value.name
              service_port = path.value.port
            }
            path = path.value.path
          }
        }
      }
    }
  }
  #######   ### tls {
  #######   ###     secret_name = "tls-secret"
  #######   ###  }

  wait_for_load_balancer = true
}

resource "aws_route53_record" "grafana_record_53" {
  zone_id = data.aws_route53_zone.hosted_zone_53.zone_id
  name    = "grafana"
  type    = "CNAME"
  ttl     = "300"
  records = [kubernetes_ingress.grafana_ingress.status.0.load_balancer.0.ingress.0.hostname]
}

resource "null_resource" "install_consul" {
  depends_on = [null_resource.install_grafana]
  provisioner "local-exec" {
    command    = "kubectl create namespace consul"
    on_failure = continue
  }
  provisioner "local-exec" {
    command    = "kubectl create secret -n consul generic consul-gossip-encryption-key --from-literal=key='uDBV4e+LbFW3019YKPxIrg=='"
    on_failure = continue
  }
  provisioner "local-exec" {
    command = "helm install consul hashicorp/consul --namespace consul -f ${path.module}/monitoring_values/consul_values.yaml"
  }
}

resource "null_resource" "update_core_dns" {
  depends_on = [null_resource.install_consul]
  provisioner "local-exec" {
    command = "export CONSUL_DNS_IP=`kubectl get svc consul-consul-dns -n consul --output jsonpath='{.spec.clusterIP}'`; envsubst < ${path.module}/monitoring_values/core_dns_config_map.tmpl > ${path.module}/monitoring_values/core_dns_config_map.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/monitoring_values/core_dns_config_map.yaml"
  }
}
