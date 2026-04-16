# LAB-002 Terraform skeleton

Ten katalog zawiera pół-wykonawczy szkielet IaC dla `LAB-002`.

## Co ten moduł robi

- tworzy jedną funkcję Lambda w `.NET 8`,
- wystawia ją przez jedno HTTP API,
- mapuje wiele route'ów do jednej integracji Lambda proxy,
- udostępnia outputy potrzebne do ręcznej walidacji.

## Założenia

- paczka wdrożeniowa istnieje w `artifacts/LAB-002/function.zip`,
- handler w kodzie odpowiada wartości:
  - `FeatureFlagsFunction::FeatureFlagsFunction.Function::FunctionHandler`,
- stage ma nazwę `$default`,
- route `$default` jest zdefiniowany osobno jako fallback.

## Szybki start

```bash
cd infra/terraform/labs/LAB-002
terraform init
terraform plan
terraform apply
```

## Weryfikacja

```bash
terraform output -raw flags_collection_url
terraform output -raw sample_flag_url
terraform output -raw default_probe_url
```

## Cleanup

```bash
terraform destroy
```
