package main

import (
	"terraform-provider-restapi/http"

	"github.com/hashicorp/terraform-plugin-sdk/plugin"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: http.Provider})
}
