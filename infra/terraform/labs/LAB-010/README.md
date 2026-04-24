# LAB-010 — Terraform (custom runtime ZIP + HTTP API)

## Co robi ten szkielet

- Tworzy funkcję Lambda z **`package_type` domyślnym (ZIP)** z pliku `artifacts/LAB-010/function.zip`.
- Ustawia runtime **`provided.al2023`** i handler **`function.handler`** (wzorzec z oficjalnego tutorial AWS — dopasuj pliki w ZIP, jeśli zmieniasz konwencję).
- Tworzy HTTP API z trasą **`GET /health`**, stage **`$default`**, integracja **`AWS_PROXY`** z **payload 2.0**.
- Dodaje uprawnienie `lambda:InvokeFunction` dla API Gateway oraz grupę logów CloudWatch.

## Zanim uruchomisz

1. Zbuduj ZIP z **`bootstrap`** (wykonywalny) i **`function.sh`** zgodnie z [Tutorial: Building a custom runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html) — pamiętaj o `chmod 755` przed spakowaniem.
2. Umieść plik jako `artifacts/LAB-010/function.zip` (ścieżka względem root repozytorium), bo `terraform plan` czyta hash pliku.

## Komendy

```bash
terraform init
terraform plan
terraform apply
terraform output
```

## TODO(lab-010)

- Uzupełnij `lab_tags` w `terraform.tfvars` (lub przez `-var`), jeśli macie politykę tagów.
- Jeśli zmieniasz nazwy plików lub handlera, zaktualizuj **`local.lambda_handler`** w `main.tf` oraz zawartość ZIP.

## Cleanup

```bash
terraform destroy
```
