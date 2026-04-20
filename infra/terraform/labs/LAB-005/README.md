# LAB-005 — Terraform (HTTP API + custom Lambda authorizer)

## Co robi ten szkielet

- Tworzy dwie funkcje Lambda:
  - authorizer (`REQUEST`, payload 2.0, simple responses),
  - backend biznesowy dla tras API.
- Tworzy HTTP API z trasami:
  - `GET /public` (bez autoryzacji),
  - `GET /profile` (z `CUSTOM` Lambda authorizerem).
- Ustawia wymagane uprawnienia `aws_lambda_permission` dla:
  - invoke backendu przez API Gateway,
  - invoke authorizera przez API Gateway.

## Zanim uruchomisz

1. Przygotuj artefakty:
   - `artifacts/LAB-005/authorizer-function.zip`
   - `artifacts/LAB-005/business-function.zip`
2. Dopasuj wartości `authorizer_handler` i `business_handler` w `main.tf` do swoich klas .NET.

## Komendy

```bash
terraform init
terraform plan
terraform apply
terraform output
```

## TODO(lab-005)

- Zastąp testowy model tokena (`Bearer ...`) własną logiką reguł tenant/plan.
- Rozważ bezpieczny cache authorizera (`authorizer_cache_ttl_seconds > 0`) po zakończeniu podstawowych testów.
- Zawęź logowanie tak, aby nigdy nie logować pełnego `Authorization`.

## Cleanup

```bash
terraform destroy
```
