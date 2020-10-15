package http

import (
	"fmt"
	"io/ioutil"
	"mime"
	"net/http"
	"regexp"
	"strings"
	"time"
	"net/url"
    "encoding/json"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
)

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

			"method": {
				Type:     schema.TypeString,
				Required: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},

			"request_body": {
				Type:     schema.TypeString,
				Optional: true,
				Elem: &schema.Schema{
					Type: schema.TypeString,
				},
			},
			"request_headers": {
				Type:     schema.TypeMap,
				Optional: true,
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
			"response_headers": {
				Type:     schema.TypeMap,
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
	method := d.Get("method").(string)
	headers := d.Get("request_headers").(map[string]interface{})
	requestbody := d.Get("request_body").(string)

	client := &http.Client{}
	if method == "GET" {
		req, err := http.NewRequest(method, uri, nil)
		if err != nil {
			return fmt.Errorf("Error creating Request: %s", err)
		}
		resp, err := client.Do(req)
		if err != nil {
			return fmt.Errorf("Error making a Request: %s", err)
		}

		defer resp.Body.Close()
		bytes, err := ioutil.ReadAll(resp.Body)
		if resp.StatusCode != 200 || resp.StatusCode != 201 || resp.StatusCode != 202 {
			return fmt.Errorf("Response code: %d Response is: %s", resp.StatusCode,bytes)
		}

		contentType := resp.Header.Get("Content-Type")
		if contentType == "" || isContentTypeAllowed(contentType) == false {
			return fmt.Errorf("Content-Type is not a text type. Got: %s", contentType)
		}
		if err != nil {
			return fmt.Errorf("Error while reading response body. %s", err)
		}

		responseHeaders := make(map[string]string)
		for k, v := range resp.Header {
			responseHeaders[k] = strings.Join(v, ", ")
		}

		d.Set("body", string(bytes))
		if err = d.Set("response_headers", responseHeaders); err != nil {
			return fmt.Errorf("Error Setting HTTP Response Headers: %s", err)
		}
		d.SetId(time.Now().UTC().String())

		return nil
	}
	if method == "POST" {
		var request_header string
		var request_header_type string
		request_header = fmt.Sprintf("%s",headers["Content-Type"])
	    request_header_type = strings.ToLower(request_header)
		if(request_header_type=="application/x-www-form-urlencoded"){
			var mapstring map[string]interface{}
			json.Unmarshal([]byte(requestbody), &mapstring)
			v := url.Values{}
			for name, value := range mapstring {
				v.Add(name, value.(string))
			}
			encoded := v.Encode()
			req, err := http.NewRequest(method, uri, strings.NewReader(encoded))
			if err != nil {
				return fmt.Errorf("Error creating Request: %s", err)
			}
			for name, value := range headers {
				req.Header.Set(name, value.(string))
			}
			resp, err := client.Do(req)
			if err != nil {
				return fmt.Errorf("Error making a Request: %s", err)
			}
			defer resp.Body.Close()
			bytes, err := ioutil.ReadAll(resp.Body)
			if(!(resp.StatusCode >= 200 && resp.StatusCode <= 202)) {
				return fmt.Errorf("Response Code: %d Response is: %s",resp.StatusCode,bytes)
			}
			contentType := resp.Header.Get("Content-Type")
			if contentType == "" || isContentTypeAllowed(contentType) == false {
					return fmt.Errorf("Content-Type is not a text type. Got: %s", contentType)
			}
			if err != nil {
				return fmt.Errorf("Error while reading response body. %s", err)
			}
			responseHeaders := make(map[string]string)
			for k, v := range resp.Header {
				responseHeaders[k] = strings.Join(v, ", ")
			}
			d.Set("body", string(bytes))
			if err = d.Set("response_headers", responseHeaders); err != nil {
				return fmt.Errorf("Error Setting HTTP Response Headers: %s", err)
			}
		}else if(!(request_header_type == "" || isContentTypeAllowed(request_header_type) == false)){
			req, err := http.NewRequest(method, uri, strings.NewReader(requestbody))
			if err != nil {
				return fmt.Errorf("Error creating Request: %s", err)
			}
			for name, value := range headers {
				req.Header.Set(name, value.(string))
			}
			resp, err := client.Do(req)
			if err != nil {
				return fmt.Errorf("Error making a Request: %s", err)
			}
			defer resp.Body.Close()
			bytes, err := ioutil.ReadAll(resp.Body)
			if (!(resp.StatusCode >= 200 && resp.StatusCode <= 202)) {
				return fmt.Errorf("Response Code: %d Response is: %s",resp.StatusCode,bytes)
			}
			contentType := resp.Header.Get("Content-Type")
			if contentType == "" || isContentTypeAllowed(contentType) == false {
					return fmt.Errorf("Content-Type is not a text type. Got: %s", contentType)
			}
			if err != nil {
				return fmt.Errorf("Error while reading response body. %s", err)
			}
			responseHeaders := make(map[string]string)
			for k, v := range resp.Header {
				responseHeaders[k] = strings.Join(v, ", ")
			}
			d.Set("body", string(bytes))
			if err = d.Set("response_headers", responseHeaders); err != nil {
				return fmt.Errorf("Error Setting HTTP Response Headers: %s", err)
			}
		}else{
			return fmt.Errorf("Unsupported Content-Type for 'request_headers'")
		}
		d.SetId(time.Now().UTC().String())
		return nil
	} else {
		if strings.HasPrefix("Get", method) || strings.HasPrefix("get", method) {
			return fmt.Errorf("There is no method named: %s \n Did you mean 'GET'?", method)
		} else if strings.HasPrefix("Post", method) || strings.HasPrefix("post", method) {
			return fmt.Errorf("There is no method named: %s \n Did you mean 'POST'?", method)
		}
		return fmt.Errorf("There is no method named: %s \n Provider only supports 'GET' and 'POST' method", method)

	}
}

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
