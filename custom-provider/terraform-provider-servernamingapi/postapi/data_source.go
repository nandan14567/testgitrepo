package postapi

import (
	// "fmt"
	// "io/ioutil"
	"fmt"
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

type Vm struct {
	Componentkey  string
	Numberservers int
}
type ReqBody struct {
	Environment         string
	System              string
	Vmallocationrequest []Vm
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
			"environment": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"system": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"componentkey": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"numberservers": {
				Type:     schema.TypeInt,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeInt,
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
	environment := d.Get("environment").(string)
	system := d.Get("system").(string)
	componentkey := d.Get("componentkey").(string)
	numberservers := d.Get("numberservers").(int)
	client := &http.Client{}

	data := ReqBody{
		Vmallocationrequest: []Vm{
			Vm{},
		},
	}
	data.Environment = environment
	data.System = system
	data.Vmallocationrequest[0].Componentkey = componentkey
	data.Vmallocationrequest[0].Numberservers = numberservers
	json_bytes, _ := json.Marshal(data)
	fmt.Printf("%s", json_bytes)

	bytesRepresentation, err := json.Marshal(data)

	if err != nil {
		log.Fatalln(err)
	}

	req, err := http.NewRequest("POST", uri, bytes.NewBuffer(bytesRepresentation))
	req.Header.Set("Content-Type", "application/json")
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

	//var result map[string]interface{}

	//json.NewDecoder(resp.Body).Decode(&result)

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
