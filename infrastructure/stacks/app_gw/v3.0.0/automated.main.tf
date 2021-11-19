module "application-gateway" {
   source = "terraform.hosting.maersk.com/maersk/application-gateway/azurerm"
   version = "3.2.4"
   ssl_certificate_data = var.ssl_certificate_data
   ssl_certificate_password = var.ssl_certificate_password
   subnet_id = var.subnet_id
   public_ip_address_id = module.public-ip.id
   https_listeners = var.https_listeners
   frontend_ports = var.frontend_ports
   backend_http_settings = var.backend_http_settings
   backend_address_pools = var.backend_address_pools
   request_routing_rules = var.request_routing_rules
   name = var.appgw_name
   resource_group_name = var.resource_group_name
}
module "public-ip" {
   source = "terraform.hosting.maersk.com/maersk/public-ip/azurerm"
   version = "1.2.1"
   name = var.pip_name
   allocation_method = var.pip_allocation_method
   resource_group = var.resource_group_name
}
