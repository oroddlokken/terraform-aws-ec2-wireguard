# A Terraform deployment for setting up a WireGuard server in AWS
This Terraform deployment sets up a WireGuard server in AWS, in a default subnet in the default VPC.

To avoid storing the WireGuard private key in the `terraform.tfstate`/`terraform.tfvars` file we store it as a SecureString in AWS SSM Parameter Store and inject it into WireGuard's `wg0.conf` on the first boot with our user-data script.

Due to the way Terraform handles changes to certain resource parameters, any changes to the `wg_*` variables will trigger a redeploy of the instance. This is intended behaviour.

On the first boot, the provided user-data script installs aws-cli (for fetching the server's private key from SSM), WireGuard and Unbound (so the server can act as a DNS resolver).

By default we do not open up SSH access to the internet, we instead rely on SSM Session Manager to be able to connect to the instance. To open up for SSH access, add your IP-address/network to the mgmt_allowed_hosts variable.

### Created resources
- EC2 instance, that is automatically configured with user-data.
- A Elastic IP address, so our instance will keep the same public IP address.
- A security group, that permits management access from a trusted network and WireGuard access from 0.0.0.0/0.
- IAM roles. 
- (Optional) SSH key pair.
- (Optional) A record in Route53 pointed at the elastic IP address. Note that this requires a Route53 hosted zone to already be present.

##  Generating private and public keys
WireGuard does not have usernames or passwords, instead it relies on public-key cryptography for authentication. The server has a pair with a private and public key, and the clients has their own pairs of private and public keys.

### How to generate private and public keys
By running `wg genkey | tee wg_private.key | wg pubkey > wg_public.key` two sets of keys are written to your current folder. One consists of you private key and the other of your public key.

User management on the server side consists of addings peers to `wg0.conf` like so:
```
[Peer]
PublicKey = gN65BkIKy1eCE9pP1wdc8ROUtkHLF2PfAqYdyYBz6EA=
AllowedIPs = 10.10.10.230/32
```

and then running `wg addconf wg0 <(wg-quick strip wg0)` as root to add your peer to the running WireGuard instance. Note that `wg addconf` will not remove peers from the running instance if they were deleted from the configuration. 

To restart WireGuard run `sudo wg-quick down wg0 && sudo wg-quick up wg0`.

## Store your WireGuard private key in SSM
In the [parameter store](https://eu-north-1.console.aws.amazon.com/systems-manager/parameters?region=eu-north-1) of your favorite region, create a SecureString parameter containing the private key you created for your server, and give it a name, like  `/ec2/vpn_node/server_privatekey`.   
The name of the parameter is the one you'll be referencing in the `wg_privkey_ssm_path` variable in `terraform.tfvars`.

## Connecting to WireGuard
After your server is created, you can connect to it with the WireGuard clients.  
Here is an example where we assume you set the allowed IP address for a client to `192.168.2.2/32`.

```
[Interface]
PrivateKey = {your_client_private_key}
Address = 192.168.2.2/32
DNS = 192.168.2.1

[Peer]
PublicKey = {your_server_public_key}
AllowedIPs = 0.0.0.0/0 # Set to 0.0.0.0/0 to route all traffic via the tunnel.
Endpoint = {your_server_fqdn}:51820
```

## Connecting to instance with SSM
* Make sure awscli is up to date
* Make sure the [Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) is installed

You can run ` aws ssm start-session --target YOUR_INSTANCE_ID` to connect to your instance. You'll be dropped in a sh-shell as the ssm-user user.

Example:
```
$ WG_INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:project,Values=WireGuard" --query 'Reservations[*].Instances[*].{Instance:InstanceId}[0].Instance' --output text)

$ aws ssm start-session --target $WG_INSTANCE_ID        

Starting session with SessionId: ove-0985344d46b163ff8

$ whoami
ssm-user
$ sudo wg
interface: wg0
  public key: kzVF236asdhasdhjferusaa/5VPQXmClH66ZRM=
  private key: (hidden)
  listening port: 51820

peer: sBh0OUvBp4uzxbasdhqsrhjxsffgas7UadOw3c=
  allowed ips: 192.168.2.3/32
  persistent keepalive: every 25 seconds
```

## Example `terraform.tfvars`:
`wg_client_public_keys` is a map with maps, one for each client.

```
aws_region             = "eu-north-1"
aws_availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
aws_account_id         = "some_account_id"

tags = {
  "project" = "WireGuard"
}

instance_type = "t3.micro"

wg_privkey_ssm_path = "/ec2/vpn_node/server_privatekey"

wg_client_public_keys = {
  "user1-desktop" = {
    "ip"         = "192.168.2.2/32"
    "public_key" = "cdcdcdcdcdcdcdcd"
  }
  "user1-phone" = {
    "ip"         = "192.168.2.3/32"
    "public_key" = "abababababababa"
  }
}
```

#### Adding SSH Public key
```
ssh_public_key = "ssh-rsa some-ssh-key"
```

#### Allowing SSH access 
```
mgmt_allowed_hosts = [
   "8.8.8.8/32",
   "9.9.9.0/24"
]
```

#### Add DNS record
```
dns_zone = "some_domain.net"
dns_fqdn = "vpn.eun1.some_domain.net"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_account\_id | The AWS account ID this deployments belongs to. | `any` | n/a | yes |
| aws\_availability\_zones | The AWS availability zones to deploy resources in. | `list(string)` | n/a | yes |
| aws\_region | The AWS region to deploy resources in. | `any` | n/a | yes |
| dns\_fqdn | (Optional) The FQDN of the A record pointing to the EC2 instance. | `string` | n/a | yes |
| dns\_zone | (Optional) The Route53 hosted zone to add DNS records to. | `string` | n/a | yes |
| instance\_name | A name to attach to the EC2 instance. | `string` | `"wireguard-vpn-node"` | no |
| instance\_type | The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance. | `string` | `"t3.micro"` | no |
| mgmt\_allowed\_hosts | A list of hosts/networks to open up SSH access to. | `list` | `[]` | no |
| sg\_wg\_allowed\_subnets | A list of hosts/networks to open up WireGuard access to. | `list` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> | no |
| ssh\_public\_key | (Optional) A SSH public key to create a key pair for in AWS EC2. | `string` | n/a | yes |
| tags | A map with tags to attach to all created resources. | `map` | `{}` | no |
| wg\_client\_public\_keys | List of maps of client IPs and public keys. See Usage in README for details. | `map(map(string))` | n/a | yes |
| wg\_persistent\_keepalive | Persistent Keepalive - useful for helping connectiona stability over NATs | `number` | `25` | no |
| wg\_privkey\_ssm\_path | The path to the WireGuard server's private key in SSM | `any` | n/a | yes |
| wg\_server\_network\_cidr | The internal network to use for WireGuard. Remember to place the clients in the same subnet. | `string` | `"192.168.2.0/24"` | no |
| wg\_server\_port | The port WireGuard should listen on. | `number` | `51820` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpn\_node\_fqdn | The FQDN of the EC2 instance. |
| vpn\_node\_public\_ip | The public IP of the EC2 instance. |