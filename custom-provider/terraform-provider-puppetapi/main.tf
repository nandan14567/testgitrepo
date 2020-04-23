data "puppetapi" "example" {
  uri                = "https://onecloudapi.deloitte.com/cloudscript/20190215/api/provision"
  accountid          = "868978391936"
  resourcelocation   = "us-east-1"
  domain             = "us.deloitte.com"
  resourceidentifier = "i-07e75c7b05182c28b"
  environment        = "NPD"
  providertype       = "aws"
  operatingsystem    = "windows"
   securitygroup      = "us"
  token              = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IllNRUxIVDBndmIwbXhvU0RvWWZvbWpxZmpZVSIsImtpZCI6IllNRUxIVDBndmIwbXhvU0RvWWZvbWpxZmpZVSJ9.eyJhdWQiOiI5ZjExZTZkYi03MTVkLTQ1YTctODg3ZS0wMWUwMGI5YmM5NjgiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zNmRhNDVmMS1kZDJjLTRkMWYtYWYxMy01YWJlNDZiOTk5MjEvIiwiaWF0IjoxNTg3NDcwMjM0LCJuYmYiOjE1ODc0NzAyMzQsImV4cCI6MTU4NzQ3NDEzNCwiYWlvIjoiNDJkZ1lIaHJmT2RRbTF5R1kvVFJzOThNNSs5ZEJnQT0iLCJhcHBpZCI6IjhhNjAwMDE3LWNlMjktNDVmYy05OTIxLTBlZDg1MjFhNGQ4MiIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzM2ZGE0NWYxLWRkMmMtNGQxZi1hZjEzLTVhYmU0NmI5OTkyMS8iLCJvaWQiOiIyNzA3NDg4ZC1hYjc1LTQzOTAtOTM5NC0wZDg5MzM0ODQzYTciLCJzdWIiOiIyNzA3NDg4ZC1hYjc1LTQzOTAtOTM5NC0wZDg5MzM0ODQzYTciLCJ0aWQiOiIzNmRhNDVmMS1kZDJjLTRkMWYtYWYxMy01YWJlNDZiOTk5MjEiLCJ1dGkiOiI4RE9BSkZLOHkwV21wbllLbXI4UEFBIiwidmVyIjoiMS4wIn0.EoCk49Ivn5IadqP6PblkUiL2z5_jQiRKj1zy8CePkn1lOZ5d0roQ-bGue28ds3sTl7k5U_0vzqvH4u0i6dUrdp0h2Pf_c1cbRWq9PaWlwrhUEF1hkFpdvlbBt7Qsws2upw_WX08y5l0X0QUuK19r5kKp9wj4uEEl9x_ea6zTOXNaANPicieD_IC_eqZphECE8QU1pi0yt5DODZkUzurzNVWTunlAkH58ybmP9GH29Kp0WKgW7KpEV1eVqU4165eBv-XPK4cPK-21H1twTm1G2umAfLoWd46RzN3ibvMuoff7J-FD5DaPdREgKY1hoiiwkpTRR7F5DhRi61DiB36MUA"


}

output "test" {
  value = "${data.puppetapi.example.body}"
}
