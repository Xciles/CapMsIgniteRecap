# Configure the Azure provider
provider "azurerm" { }

resource "azurerm_resource_group" "CapIgniteRG" {
    name = "CapIgnite-RG"
    location = "westeurope"
}

resource "azurerm_resource_group" "CapIgniteSqlRG" {
    name = "CapIgniteSql-RG"
    location = "westeurope"
}

# Web
resource "azurerm_app_service_plan" "CapIgniteAppServicePlan" {
    name                = "CapIgniteAppServicePlan"
    location            = "${azurerm_resource_group.CapIgniteRG.location}"
    resource_group_name = "${azurerm_resource_group.CapIgniteRG.name}"
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "CapIgniteAppServiceWeb" {
    name                = "CapIgniteAppServiceWeb"
    location            = "${azurerm_resource_group.CapIgniteRG.location}"
    resource_group_name = "${azurerm_resource_group.CapIgniteRG.name}"
    app_service_plan_id = "${azurerm_app_service_plan.CapIgniteAppServicePlan.id}"
	site_config {
		always_on 		= true
	}
	app_settings {
		"ASPNETCORE_ENVIRONMENT" 		= "Production"
		"Test" 							= "${local.blobString}"
	}
}

# Database
resource "azurerm_sql_server" "CapIgniteSql" {
	name                         = "capignitesqlserver"
	resource_group_name          = "${azurerm_resource_group.CapIgniteSqlRG.name}"
	location                     = "${azurerm_resource_group.CapIgniteSqlRG.location}"
	version                      = "12.0"
	administrator_login          = "DbAdmin"
	administrator_login_password = "Iyghwuieygt837UYgukygoiUY89727"

	tags {
		environment = "production"
	}
}

resource "azurerm_sql_database" "CapIgniteSql" {
	name                		= "CapIgniteDbTest"
	resource_group_name 		= "${azurerm_resource_group.CapIgniteSqlRG.name}"
	location                    = "${azurerm_resource_group.CapIgniteSqlRG.location}"
	server_name 				= "${azurerm_sql_server.CapIgniteSql.name}"
	edition 					= "Standard"
	requested_service_objective_name = "S0"

	tags {
		environment = "production"
	}
}