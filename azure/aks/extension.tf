resource "azurerm_kubernetes_cluster_extension" "extension-flux" {
  name           = "ext-fluxcd"
  cluster_id     = azurerm_kubernetes_cluster.aks-aci-virtual-node.id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "flux-configuration" {
  name       = "config-fluxcd"
  cluster_id = azurerm_kubernetes_cluster.aks-aci-virtual-node.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/welljustfordemo/aks-fluxcd-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.extension-flux
  ]
}