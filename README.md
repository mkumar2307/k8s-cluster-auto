Step-by-step guide to create a Kubernetes cluster with automation script.

### 🔧 How to Use

1. Transfer the script to all 4 nodes (master and workers).       

2. Run on the master node:

```bash
bash k8s_cluster_setup.sh master
```

This will:     

Disable swap        
Install Docker and Kubernetes components      
Initialize the master        
Install Calico network       
Generate a join_command.sh for workers        

3. Run on each worker node:

```bash
bash k8s_cluster_setup.sh worker
```

This will:       
Disable swap       
Install Docker and Kubernetes components        
Execute the join command (we need to copy join_command.sh from the master)

To copy join_command.sh from master node:         

```bash
scp join_command.sh ubuntu@<worker-node-ip>:~
```

Repeat for each worker node.        
SSH into each worker node and run:

```bash
bash join_command.sh
```

Note: if you didn’t use a script, just paste the full kubeadm join command directly into the terminal.          

🧪 Verify the Cluster         

Back on the master node:        
```bash
kubectl get nodes
```

You should see all nodes in Ready state.
