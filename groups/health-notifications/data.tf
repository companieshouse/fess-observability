data "vault_generic_secret" "secrets" {
  path = local.vault_secret_path
}