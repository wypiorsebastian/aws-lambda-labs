# LAB-006 — Terraform (HTTP API + observability baseline)

## Co robi ten szkielet

- Tworzy jedną funkcję Lambda (`dotnet8`) z aktywnym tracingiem X-Ray.
- Tworzy HTTP API z trasami:
  - `GET /health`
  - `GET /orders/{orderId}`
  - `GET /fail`
- Konfiguruje `$default` stage z access logging do CloudWatch Logs (format JSON).
- Ustawia wymagane uprawnienia IAM:
  - `AWSLambdaBasicExecutionRole`
  - `AWSXRayDaemonWriteAccess`
- Dodaje `aws_lambda_permission` dla wywołań API Gateway -> Lambda.

## Zanim uruchomisz

1. Przygotuj artefakt:
   - `artifacts/LAB-006/function.zip`
2. Dopasuj `lambda_handler` w `main.tf` do klasy w projekcie `src/LAB-006/...`.

## Komendy

```bash
terraform init
terraform plan
terraform apply
terraform output
```

## TODO(lab-006)

- Dodaj do kodu funkcji Powertools Logger/Tracing/Metrics.
- Ustal bezpieczny zestaw pól w structured logs (bez danych wrażliwych).
- Dodaj własne metryki biznesowe (np. licznik błędów domenowych).

## Cleanup

```bash
terraform destroy
```
