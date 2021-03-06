output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "Gives the VPC ID created"
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks_cluster.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks_cluster.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks_cluster.config_map_aws_auth
}

output "cluster_name" {
  value       = local.cluster_name
  description = "EKS Cluster name"
}

output "load_balancer_hostname" {
  value = kubernetes_service.java.status.0.load_balancer.0.ingress.0.hostname
}