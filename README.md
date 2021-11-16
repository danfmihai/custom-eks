# Custom EKS

This setup will create a custom EKS using modules. VPC and EKS created with workers done with an AutoScaling Group (spot,on-demand - EC2)

After the EKS is provisioned you can deploy on it any apps

This EKS will have a ELB LoadBalancer provided by Amazon, so if you deploy an app with a service as LoadBalancer, app will be available through the ELB DNS.


## Usage

```
terraform init
terraform plan
terraform apply -auto-approve

```


## Connect to EKS

In order to connect to the EKS you need to copy the file that's created in `.kube/` folder in your `~/.kube/` folder and make sure `kubectl` is installed. After you copy the file you execute the commands:  

```
kubectl config current-context
kubectl config get-contexts
kubectl config use-context <name of the EKS context>
```

To view the newly deployment use:

```
kubectl get deployments
kubectl get pods
```

References:

https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest#input_worker_groups_launch_template

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

