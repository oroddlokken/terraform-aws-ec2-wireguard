# A Terraform deployment for setting up a WireGuard server in AWS
This Terraform deployment sets up a WireGuard server in AWS, in a default subnet in the default VPC.

To avoid storing the WireGuard private key in the state/tfvars file we store it in SSM and fetch it at the first boot.

This is a POC just to get something up and running quickly. Currently any changes to the peers config in terraform.tfvars triggers a redeploy of the EC2 instance.

Resources we create:
- A EC2 instance that sets up WireGuard and Unbound at first boot via user-data
- Elastic IP for the EC2 instance
- IAM instance role with policies to allow fetching of the secret from SSM
- DNS records for the EC2 instance, but this should be optional
- Security groups for the instance, that allows SSH from trusted management networks and WireGuard traffic from anywhere.
- A key pair, this should probably be optional as well so you could supply an already existing one.

##  Generating private and public keys
### Private keys
```wg genkey | tee server_private_key | wg pubkey > server_public_key```

### Public key for your client
```wg genkey | tee client_private_key | wg pubkey > client_public_key```

## Upload WireGuard private key to SSM
In the [parameter store](https://eu-west-1.console.aws.amazon.com/systems-manager/parameters?region=eu-west-1) of your favorite region, create a parameter with the contents of your Wireguard private key, e.g. `/ec2/vpn_node/server_privatekey`


## Example `terraform.tfvars`:
```
aws_region             = "eu-north-1"
aws_availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
aws_account_id         = "your_account_id"

ssh_public_key = "some ssh-key"

dns_zone = "myzone.net"
dns_fqdn = "vpn.eun1.aws.myzone.net"

instance_type = "t3.micro"

wg_privkey_ssm_path = "/ec2/vpn_node/server_privatekey"

mgmt_allowed_hosts = [
  "8.8.8.8/32"
]

wg_client_public_keys = {
    "user1-desktop" = {
        "ip" = "192.168.2.2/32"
        "public_key" = "some_public_key"
    }
    "user1-iphone" = {
        "ip" = "192.168.2.3/32"
        "public_key" = "some_public_key"
    }
}
```
