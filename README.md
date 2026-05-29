## Filmdrop Filmdrop-UI Terraform Module

This repository contains the Terraform module to build and deploy the React application for the [Filmdrop Filmdrop-UI](https://github.com/Element84/filmdrop-ui), and is part of the larger [Filmdrop AWS Terraform modules](https://github.com/Element84/filmdrop-aws-tf-modules) ecosystem.

The Filmdrop Filmdrop-UI provides an out-of-the-box open source solution for searching, visualizing, and interacting with geospatial data catalogs through STAC (Spatio-Temporal Asset Catalogs) via a Leaflet map and React application.

This Terraform module provisions the necessary infrastructure to deploy the Filmdrop-UI in an existing AWS account and organization. It can be deployed standalone or integrated into a comprehensive Filmdrop deployment, as demonstrated in the `default.tfvars` in the [Filmdrop AWS Terraform modules](https://github.com/Element84/filmdrop-aws-tf-modules) repository.

README generated with AI assistance

### Documentation created with assistance of AI


## Overview

This module automates the deployment of the Filmdrop Filmdrop-UI by:

1. **Creating an AWS CodeBuild project** that downloads, builds, and deploys the Filmdrop Filmdrop-UI React application
2. **Provisioning S3 buckets** for storing build configurations and hosting the built application
3. **Managing IAM roles and policies** for CodeBuild execution

### Architecture

The module follows this workflow:

```
Terraform Apply
    ↓
CodeBuild Project Created
    ↓
Build Triggered Automatically
    ↓
1. Download FilmDrop UI from GitHub
2. Inject custom config & logo
3. Build React app (npm install + build)
4. Deploy to S3 bucket
    ↓
Filmdrop-UI Available in S3
```

The CodeBuild project runs inside a VPC and requires:
- Internet access (via NAT Gateway or VPC Endpoints) to download packages from GitHub and npm
- S3 access to store the built application
- CloudWatch Logs access for build logging

## Prerequisites

Before using this module, ensure you have:

1. **AWS Account** with appropriate permissions to create:
   - CodeBuild projects
   - IAM roles and policies
   - S3 buckets
   - CloudWatch Log Groups
   - VPC resources (if using VPC configuration)

2. **VPC Setup** with:
   - Private subnets with internet access (NAT Gateway or VPC Endpoints for S3, CloudWatch Logs, and general internet access)
   - Security groups allowing outbound traffic
   - VPC ID and subnet IDs

3. **S3 Buckets**:
    - The module automatically creates an S3 bucket to hold the CodeBuild configuration (buildspec.yml)
    - *Requires* an already existing S3 bucket for the built application to be deployed to (specified via `filmdrop_ui_bucket_name` variable)

4. **Configuration Files**:
   - **Filmdrop UI Config JSON** (`./utils/config.dev.json`): Configuration file for the Filmdrop-UI application (see [Filmdrop UI documentation](https://github.com/Element84/filmdrop-ui) for structure)
   - **Logo File** (`./utils/logo.png`): Custom logo for branding


## Usage

Refer to `main.tf` in the `utils/cicd` directory for a reference of how to stand this module up on it's own.  This is the configuration utilized during build and tear down tests during release.  


## How It Works

### 1. CodeBuild Project

The module creates an AWS CodeBuild project that:
- Uses the `aws/codebuild/amazonlinux2-x86_64-standard:5.0` image
- Runs in your VPC for secure access to resources
- Executes the build process defined in [`buildspec.yml`](buildspec.yml)

### 2. Build Process

The [`buildspec.yml`](buildspec.yml) defines the build steps:

1. **Download**: Fetches the specified release of FilmDrop UI from GitHub using the defined version in `main.tf`
2. **Configure**: Injects your custom configuration and logo files
3. **Build**: Runs `npm install` and `npm run build` to compile the React application
4. **Deploy**: Syncs the built files to your S3 bucket

### 3. Automatic Triggers

The module includes a `null_resource` that automatically triggers a CodeBuild build when:
- The module is first applied
- AWS Region changes
- The FilmDrop UI release tag changes
- The configuration file changes
- The S3 bucket name changes
- The buildspec changes

### 4. Build Monitoring

Build logs are sent to CloudWatch Logs at `/filmdrop/filmdrop_ui_build` for debugging and monitoring.

## Configuration File Format

Your `config.json` file should follow the [Filmdrop UI configuration schema](https://github.com/Element84/filmdrop-ui/blob/main/CONFIGURATION.md). Example:

```json
{
  "APP_NAME": "FilmDrop Filmdrop",
  "PUBLIC_URL": "https://filmdrop.dev.example.com",
  "LOGO_URL": "./logo.png",
  "LOGO_ALT": "FilmDrop Filmdrop Logo",
  "STAC_API_URL": "https://stac-api.dev.example.com",
  "DEFAULT_COLLECTION": "some-collection",
  "STAC_LINK_ENABLED": true,
  "SEARCH_BY_GEOM_ENABLED": true,
  "SHOW_ITEM_AUTO_ZOOM": true,
  "DASHBOARD_BTN_URL": "https://dashboard.dev.example.com",
  "ANALYZE_BTN_URL": "https://analytics.dev.example.com/",
  "SEARCH_MIN_ZOOM_LEVELS": {},
  "SCENE_TILER_URL": "https://titiler.dev.example.com",
  "SCENE_TILER_PARAMS": {},
  "MOSAIC_TILER_URL": "https://titiler.dev.example.com",
  "MOSAIC_TILER_PARAMS": {},
  "POPUP_DISPLAY_FIELDS": {}
}
```

## Important Notes

### Base64 Encoding
The `filmdrop_ui_config` and `filmdrop_ui_logo` variables expect **base64-encoded content**, not file paths. Always use:

```hcl
filmdrop_ui_config = base64encode(file("path/to/config.json"))
filmdrop_ui_logo   = base64encode(file("path/to/logo.png"))
```

### Release Tags
The `filmdrop_ui_release_tag` must:
- Start with `v` (e.g., `v6.1.1-0`)
- Be version 4.0.0 or higher
- Match a valid [Filmdrop UI release tag](https://github.com/Element84/filmdrop-ui/releases)


## License

This project is licensed under the Apache License 2.0 - see the [`LICENSE`](LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_filmdrop_ui_bucket_name"></a> [filmdrop\_ui\_bucket\_name](#input\_filmdrop\_ui\_bucket\_name) | Name of the S3 bucket where the built FilmDrop UI application will be deployed | `string` | n/a | yes |
| <a name="input_filmdrop_ui_config"></a> [filmdrop\_ui\_config](#input\_filmdrop\_ui\_config) | The base64 encoded file contents of the Filmdrop UI Deployment Config File | `string` | n/a | yes |
| <a name="input_filmdrop_ui_logo"></a> [filmdrop\_ui\_logo](#input\_filmdrop\_ui\_logo) | The base64 encoded file contents of the supplied custom logo | `string` | n/a | yes |
| <a name="input_filmdrop_ui_logo_file"></a> [filmdrop\_ui\_logo\_file](#input\_filmdrop\_ui\_logo\_file) | File of the supplied custom logo | `string` | n/a | yes |
| <a name="input_filmdrop_ui_release_tag"></a> [filmdrop\_ui\_release\_tag](#input\_filmdrop\_ui\_release\_tag) | FilmDrop UI Release | `string` | n/a | yes |
| <a name="input_filmdrop_ui_source_url"></a> [filmdrop\_ui\_source\_url](#input\_filmdrop\_ui\_source\_url) | Optional override for the FilmDrop UI source archive URL fetched by CodeBuild. Lets you point at a fork (e.g. https://github.com/<your-fork>/filmdrop-ui/archive/refs/tags/<tag>.tar.gz). When set, filmdrop\_ui\_release\_tag may be any string (semver not required). When empty, defaults to the Element84/filmdrop-ui release tarball. | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | FilmDrop VPC ID | `string` | n/a | yes |
| <a name="input_vpc_private_subnet_ids"></a> [vpc\_private\_subnet\_ids](#input\_vpc\_private\_subnet\_ids) | List of private subnet ids in the FilmDrop vpc | `list(string)` | `[]` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security groups in the FilmDrop vpc | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->