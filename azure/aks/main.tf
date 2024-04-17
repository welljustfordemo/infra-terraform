data "azurerm_resource_group" "rg" {
  name = "devops"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "default-nodepool-subnet" {
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "aci-nodepool-subnet" {
  name                 = "aci"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = ["10.10.3.0/24"]

  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_kubernetes_cluster" "aks-aci-virtual-node" {
  name                 = "${var.prefix}-k8s"
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  dns_prefix           = "${var.prefix}-k8s"
  azure_policy_enabled = false

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
    vnet_subnet_id      = azurerm_subnet.default-nodepool-subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  #  network_profile {
  #    network_plugin      = "azure"
  #    network_mode        = "bridge"
  #    network_policy      = "cilium"
  #    ebpf_data_plane     = "cilium"
  #    network_plugin_mode = "overlay"
  #  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  service_mesh_profile {
    mode                             = "Istio"
    internal_ingress_gateway_enabled = true
    external_ingress_gateway_enabled = true
  }

  aci_connector_linux {
    subnet_name = azurerm_subnet.aci-nodepool-subnet.name
  }

  tags = {
    Environment = "Lab"
    CanDelete   = "Yes"
  }
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = azurerm_subnet.aci-nodepool-subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks-aci-virtual-node.aci_connector_linux[0].connector_identity[0].object_id
}