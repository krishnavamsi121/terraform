#CLI Commands

- terraform apply -var-file = another-variables.tfvars

- terraform apply -var="db_user=myuser" -var="db_pass=SOMETHING_SECURE"

Ideally sensitive values are stored in Github secrets or AWS Secret Manager or Vault