locals {
  AppNameHash            = substr(lower(md5("${var.AppName}")), 0, 6)
  VmNameHash            = substr(lower(md5("${var.VmName}")), 0, 3)
}