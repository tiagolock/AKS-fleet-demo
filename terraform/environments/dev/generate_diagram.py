#!/usr/bin/env python3
"""
Generate architecture diagram for AKS Fleet Demo using the diagrams library.
"""

from diagrams import Diagram, Cluster
from diagrams.azure.compute import KubernetesServices, AKS
from diagrams.azure.network import VirtualNetworks, Subnets
from diagrams.azure.general import ResourceGroups

# Create the diagram
with Diagram("AKS Fleet Multi-Region Architecture", filename="architecture_diagram", outformat="png", show=False):
    
    # Cluster 1 in East US
    with Cluster("Region: East US"):
        rg1 = ResourceGroups("rg-aks-cluster-1")
        vnet1 = VirtualNetworks("vnet-aks-cluster-1\n10.0.0.0/16")
        subnet1 = Subnets("snet-aks-cluster-1\n10.0.1.0/24")
        
        with Cluster("AKS Cluster 1\naks-cluster-1"):
            aks1 = KubernetesServices("Cluster\n(K8s 1.28)")
        
        rg1 >> vnet1 >> subnet1 >> aks1
    
    # Cluster 2 in East US 2
    with Cluster("Region: East US 2"):
        rg2 = ResourceGroups("rg-aks-cluster-2")
        vnet2 = VirtualNetworks("vnet-aks-cluster-2\n10.0.0.0/16")
        subnet2 = Subnets("snet-aks-cluster-2\n10.0.2.0/24")
        
        with Cluster("AKS Cluster 2\naks-cluster-2"):
            aks2 = KubernetesServices("Cluster\n(K8s 1.28)")
        
        rg2 >> vnet2 >> subnet2 >> aks2
    
    # Fleet Manager in East US
    with Cluster("Region: East US\n(Fleet Hub)"):
        rg_fleet = ResourceGroups("rg-aks-fleet")
        
        with Cluster("AKS Fleet Manager\nfleet-manager"):
            fleet = AKS("Fleet Hub")
        
        rg_fleet >> fleet
    
    # Connections
    aks1 >> fleet
    aks2 >> fleet
