#!/usr/bin/env python3
"""
Generate architecture diagram for AKS Fleet Demo with Private Clusters, Jump Host, and VNet Peering.
"""

from diagrams import Diagram, Cluster
from diagrams.azure.compute import KubernetesServices, AKS
from diagrams.azure.network import VirtualNetworks, Subnets
from diagrams.azure.general import ResourceGroups
from diagrams.azure.compute import VM

# Create the diagram
with Diagram("AKS Fleet Multi-Region Architecture with VNet Peering", filename="architecture_diagram", outformat="png", show=False):
    
    # Jump Host / Bastion in public VNet
    with Cluster("Region: East US (Public)"):
        rg_bastion = ResourceGroups("rg-bastion")
        vnet_bastion = VirtualNetworks("vnet-bastion\n172.16.0.0/16")
        subnet_jump = Subnets("snet-jumphost\n172.16.0.0/24")
        
        with Cluster("Jump Host / Bastion"):
            jumphost = VM("Jump Host\n(vm-jumphost)")
        
        rg_bastion >> vnet_bastion >> subnet_jump >> jumphost
    
    # Cluster 1 in East US - Private
    with Cluster("Region: East US (Private)"):
        rg1 = ResourceGroups("rg-aks-cluster-1")
        vnet1 = VirtualNetworks("vnet-aks-cluster-1\n10.0.0.0/16")
        subnet1 = Subnets("snet-aks-cluster-1\n10.0.1.0/24")
        
        with Cluster("AKS Cluster 1 (Private)\naks-cluster-1"):
            aks1 = KubernetesServices("Cluster\n(K8s 1.28)")
        
        rg1 >> vnet1 >> subnet1 >> aks1
    
    # Cluster 2 in East US 2 - Private
    with Cluster("Region: East US 2 (Private)"):
        rg2 = ResourceGroups("rg-aks-cluster-2")
        vnet2 = VirtualNetworks("vnet-aks-cluster-2\n10.0.0.0/16")
        subnet2 = Subnets("snet-aks-cluster-2\n10.0.2.0/24")
        
        with Cluster("AKS Cluster 2 (Private)\naks-cluster-2"):
            aks2 = KubernetesServices("Cluster\n(K8s 1.28)")
        
        rg2 >> vnet2 >> subnet2 >> aks2
    
    # Fleet Manager in East US
    with Cluster("Region: East US (Fleet Hub)"):
        rg_fleet = ResourceGroups("rg-aks-fleet")
        
        with Cluster("AKS Fleet Manager\nfleet-manager"):
            fleet = AKS("Fleet Hub")
        
        rg_fleet >> fleet
    
    # Private DNS Zone (shown separately)
    dns_zone = ResourceGroups("Private DNS Zone\nprivatelink.hcp.eastus.azmk8s.io")
    
    # Connections - VNet Peering between clusters
    aks1 - aks2  # VNet Peering between clusters
    
    # Connections - Bastion to clusters
    jumphost >> aks1
    jumphost >> aks2
    
    # Clusters to Fleet
    aks1 >> fleet
    aks2 >> fleet
    
    # DNS Zone links
    dns_zone >> vnet1
    dns_zone >> vnet2
    dns_zone >> vnet_bastion
