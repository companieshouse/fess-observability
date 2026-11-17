locals {
    vault_secret_path = "applications/${var.aws_profile}/${var.environment}/fess/monitoring"

    xmatters_webhook_url = format(
        "https://%s%s",
        var.xmatters_host,
        jsondecode(data.vault_generic_secret.secrets.data_json).xmatters_endpoint
    )
}