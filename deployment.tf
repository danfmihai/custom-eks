data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# change context
resource "null_resource" "java" {
  depends_on = [module.eks_cluster]
  provisioner "local-exec" {
    command = "aws eks --region ${local.region}  update-kubeconfig --name $AWS_CLUSTER_NAME"
    environment = {
      AWS_CLUSTER_NAME = "${local.cluster_name}"
    }
  }
}

#create deployment
resource "kubernetes_deployment" "java" {
  metadata {
    name = "microservice-deployment"
    labels = {
      app = "java-microservice"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "java-microservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "java-microservice"
        }
      }
      spec {
        container {
          image = "337204325105.dkr.ecr.us-east-1.amazonaws.com/java-app:latest"
          name  = "java-microservice-container"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

#create service
resource "kubernetes_service" "java" {
  depends_on = [kubernetes_deployment.java]
  metadata {
    name = "java-microservice-service"
  }
  spec {
    selector = {
      app = "java-microservice"
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}