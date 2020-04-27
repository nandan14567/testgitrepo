package postapi

import (
	// "fmt"
	// "io/ioutil"

	"io/ioutil"
	"mime"

	// "net/http"
	"regexp"
	"strings"
	"time"

	// "net/url"
	//"strconv"
	// //"bytes"
	"bytes"
	"encoding/json"
	"log"
	"net/http"

	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
)

type ReqBody struct {
	AccountID          string
	ResourceLocation   string
	Domain             string
	ResourceIdentifier string
	Environment        string
	Provider           string
	OperatingSystem    string
	SecurityGroup      string
}

func dataSource() *schema.Resource {
	return &schema.Resource{
		Read: dataSourceRead,

		Schema: map[string]*schema.Schema{
			"uri": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"accountid": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"resourcelocation": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"domain": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"resourceidentifier": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"environment": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"providertype": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"operatingsystem": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"securitygroup": {
				Type:     schema.TypeString,
				Optional: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"token": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"body": {
				Type:     schema.TypeString,
				Computed: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
		},
	}
}

func dataSourceRead(d *schema.ResourceData, meta interface{}) error {

	uri := d.Get("uri").(string)
	accountid := d.Get("accountid").(string)
	resourcelocation := d.Get("resourcelocation").(string)
	domain := d.Get("domain").(string)
	resourceidentifier := d.Get("resourceidentifier").(string)
	environment := d.Get("environment").(string)
	provider := d.Get("providertype").(string)
	operatingsystem := d.Get("operatingsystem").(string)
	securitygroup := ""
	if d.Get("securitygroup") != "" {
		securitygroup = d.Get("securitygroup").(string)
	}

	token := d.Get("token").(string)

	client := &http.Client{}

	data := ReqBody{}
	data.Environment = environment
	data.AccountID = accountid
	data.ResourceLocation = resourcelocation
	data.Domain = domain
	data.ResourceIdentifier = resourceidentifier
	data.Provider = provider
	data.OperatingSystem = operatingsystem

	if d.Get("securitygroup") != "" {
		securitygroup = d.Get("securitygroup").(string)
		data.SecurityGroup = securitygroup
	}

	bytesRepresentation, err := json.Marshal(data)
	if err != nil {
		log.Fatalln(err)
	}

	req, err := http.NewRequest("POST", uri, bytes.NewBuffer(bytesRepresentation))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", token)
	if err != nil {
		log.Println(err)
	}
	resp, err := client.Do(req)
	if err != nil {
		log.Println(err)
	}
	bytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(err)
	}

	resp.Body.Close()
	if err != nil {
		log.Fatal(err)
	}

	d.Set("body", string(bytes))
	d.SetId(time.Now().UTC().String())

	return nil
}

// This is to prevent potential issues w/ binary files
// and generally unprintable characters
// See https://github.com/hashicorp/terraform/pull/3858#issuecomment-156856738
func isContentTypeAllowed(contentType string) bool {

	parsedType, params, err := mime.ParseMediaType(contentType)
	if err != nil {
		return false
	}

	allowedContentTypes := []*regexp.Regexp{
		regexp.MustCompile("^text/.+"),
		regexp.MustCompile("^application/json$"),
		regexp.MustCompile("^application/samlmetadata\\+xml"),
	}

	for _, r := range allowedContentTypes {
		if r.MatchString(parsedType) {
			charset := strings.ToLower(params["charset"])
			return charset == "" || charset == "utf-8"
		}
	}

	return false
}
