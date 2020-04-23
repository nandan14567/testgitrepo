package main

import (
	"terraform-provider-puppetapi/postapi"

	"github.com/hashicorp/terraform-plugin-sdk/plugin"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: postapi.Provider})
}
