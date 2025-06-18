# Multi-Region API Gateway Deployment

This module now supports multi-region deployment with Route 53 latency-based routing for improved global performance and availability.

## Architecture

The multi-region setup creates:

1. **Regional API Gateways**: Separate API Gateway instances in each specified region
2. **Regional Certificates**: ACM certificates for each regional subdomain
3. **Latency-based Routing**: Route 53 records that route traffic to the nearest healthy region
4. **Health Checks**: Route 53 health checks to monitor regional API availability

## Usage

### Single Region (Original)

To use the original single-region deployment, use the existing files:
- `main.tf`
- `variables.tf` 
- `certificate.tf`
- `domain.tf`

### Multi-Region

To deploy across multiple regions, use the multi-region files:

```hcl
# Use main-multi-region.tf as your main.tf
# Include certificate-multi-region.tf
# Include route53-multi-region.tf  
# Include outputs-multi-region.tf

module "api_gateway" {
  source = "./path/to/this/module"
  
  # Multi-region configuration
  regions = ["us-east-1", "eu-west-1", "ap-southeast-1"]
  
  # Standard configuration
  env                      = "prod"
  api_name                 = "my-api"
  api_domain               = "api.example.com"
  route53_zone_id          = "Z1D633PJN98FT9"
  api_description          = "My Multi-Region API"
  
  # API configuration
  api_authorizers = {
    bearer_auth = {
      type = "bearer"
      lambda = {
        file    = "auth.py"
        runtime = "python3.9"
      }
    }
  }
  
  api_paths = {
    "/users" = {
      get = {
        lambda = {
          file = "get_users.py"
        }
      }
      post = {
        security = ["bearer_auth"]
        lambda = {
          file = "create_user.py"
        }
      }
    }
  }
}
```

## Domain Structure

The multi-region setup creates regional subdomains:

- **Primary Domain**: `api.example.com` (with latency-based routing)
- **Regional Domains**: 
  - `us-east-1.api.example.com`
  - `eu-west-1.api.example.com`
  - `ap-southeast-1.api.example.com`

## Health Checks

Each regional deployment includes:
- HTTPS health checks on `/health` endpoint
- 30-second check intervals
- 3 failure threshold before marking unhealthy
- Automatic failover to healthy regions

## Outputs

The multi-region setup provides these outputs:

- `api_gateway_regional_ids`: Map of regional API Gateway IDs
- `api_gateway_regional_invoke_urls`: Map of regional invoke URLs
- `api_primary_domain_name`: Primary domain with latency routing
- `route53_health_check_ids`: Health check IDs for monitoring
- `certificate_arns`: Regional certificate ARNs

## Migration from Single to Multi-Region

1. **Backup your state**: Always backup your Terraform state before migration
2. **Update configuration**: Switch to using the multi-region files
3. **Plan carefully**: Review the terraform plan to understand changes
4. **Migrate gradually**: Consider blue-green deployment for production

## Monitoring

Monitor your multi-region deployment using:
- Route 53 health check status in CloudWatch
- API Gateway metrics per region
- Lambda function metrics across regions
- Certificate expiration alerts

## Cost Considerations

Multi-region deployment increases costs:
- Additional API Gateway instances
- Route 53 health checks ($0.50/month per check)
- Additional ACM certificates (free)
- Cross-region Lambda invocations
- CloudWatch logs in multiple regions