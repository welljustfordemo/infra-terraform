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

  linux_profile {
    admin_username = "pengfei"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1D3zqSEJxdQkO59hcoJNzHmxuaQ0af1oauHjBKBjMeheveKgIXztwqG/TiBb7LOkHBi0cKipnmbdYpxQ2szehrLNGtGCP8OMN346F5sRd25twK0YPRGClCxM1UtmREn5LdknlVd1wwulfX21JX4+6MfhOMe8UJdHNsSchUpFgJvdBwCMHAW1tTkWAdgvss1SRfP9ce1fnIQjXZqrrU1IRUgNQmN1VPimNwjtqgNLCITF+a21XvZjLTlv9n8q8vS0tpNEta5D/UHNmelO9oiIGr2LYbHeH/JmjoPDScpfw7jhvrE9HYFCyNBmUhQK8b+z4QkPYK8do0BmrZrUANps0xT2a5RvspOr+8n5c3hxzAerO9wzfNH2EDj5m/ieLoO/UXFQkZFcw1jwh1oQsmsVJW6ycbTcfedQx4IaA4WTA0LoUOKdeRpX75gyqCzm4Z+mBDSaiEAwXFygnabHCt+bh5SEo+EoEcUX9BPncwEM2JA95/Svdl7O1lZGsqqPlz68= andrew@AndrewsacStudio"
    }
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