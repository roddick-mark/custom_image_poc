module "app_gw" {
   source = "./../../../stacks/app_gw/v3.0.0/"
   ssl_certificate_data = var.ssl_certificate_data
   ssl_certificate_password = var.ssl_certificate_password
   subnet_id = var.subnet_id
   frontend_ports = var.frontend_ports
   backend_address_pools = var.backend_address_pools
   backend_http_settings = var.backend_http_settings
   https_listeners = var.https_listeners
   request_routing_rules = var.request_routing_rules
   appgw_name = var.appgw_name
   pip_name = var.pip_name
   pip_allocation_method = var.pip_allocation_method
   resource_group_name = var.resource_group_name
}
