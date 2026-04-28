variable "vpc_private_subnet_ids" {
  description = "List of private subnet ids in the FilmDrop vpc"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of security groups in the FilmDrop vpc"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "FilmDrop VPC ID"
  type        = string
}

variable "filmdrop_ui_release_tag" {
  description = "FilmDrop UI Release"
  type        = string
  validation {
    condition     = substr(var.filmdrop_ui_release_tag, 0, 1) == "v" && substr(var.filmdrop_ui_release_tag, 1, 2) >= 4
    error_message = "The filmdrop_ui_release_tag value must be a filmdrop-ui release >= v4.0.0"
  }
}

variable "filmdrop_ui_config" {
  description = "The base64 encoded file contents of the Filmdrop UI Deployment Config File"
  type        = string
}

variable "filmdrop_ui_logo_file" {
  description = "File of the supplied custom logo"
  type        = string
}

variable "filmdrop_ui_logo" {
  description = "The base64 encoded file contents of the supplied custom logo"
  type        = string
}

variable "filmdrop_ui_bucket_name" {
  description = "Name of the S3 bucket where the built FilmDrop UI application will be deployed"
  type        = string
}

variable "filmdrop_ui_source_url" {
  description = "Optional override for the FilmDrop UI source archive URL fetched by CodeBuild. Lets you point at a fork (e.g. https://github.com/<your-fork>/filmdrop-ui/archive/refs/tags/<tag>.tar.gz). The tag must still match filmdrop_ui_release_tag so the extracted directory name (filmdrop-ui-<tag without leading v>) is correct. When empty, defaults to the Element84/filmdrop-ui release tarball."
  type        = string
  default     = ""
}
