# LAB-001 — Terraform skeleton

Szkielet IaC dla LAB-001: Lambda .NET 8 (zip deployment) + HTTP API Gateway.

## Przed uruchomieniem

1. Zbuduj i spakuj funkcję Lambda (patrz `docs/labs/runs/LAB-001.md`, krok 3)
2. Upewnij się, że `function.zip` istnieje pod ścieżką wskazaną w `var.zip_path`
3. Skonfiguruj credentials AWS

## Uruchomienie

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

Pamiętaj o ręcznym usunięciu CloudWatch Log Group jeśli nie dodałeś go do Terraform.

## Zmienne

| Zmienna         | Domyślna wartość                | Opis                              |
|-----------------|---------------------------------|-----------------------------------|
| `aws_region`    | `eu-central-1`                  | Region AWS                        |
| `function_name` | `health-function-lab001`        | Nazwa funkcji Lambda              |
| `zip_path`      | `../../../../function.zip`      | Ścieżka do deployment package     |
