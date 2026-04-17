# LAB-003 — Terraform (konfiguracja i sekrety)

Moduł tworzy:

- sekret demonstracyjny w **AWS Secrets Manager** (JSON),
- funkcję **Lambda .NET 8** z zmiennymi środowiskowymi (w tym **tylko referencja** `SECRET_ARN`, nie wartość sekretu),
- politykę IAM **GetSecretValue** na ten sekret,
- **HTTP API** z jedną trasą `GET /config`.

## Wymagania przed `apply`

- plik `artifacts/LAB-003/function.zip` zbudowany z projektu `ConfigLabFunction` (patrz runbook `docs/labs/runs/LAB-003.md`).

## Przykładowe ustawienie „środowiska”

```bash
terraform apply -var="app_env=test"
```

To zmienia wyłącznie zmienną `APP_ENV` w Lambdzie (etykieta środowiska). Nie zastępuje pełnego modelu wielu kont AWS ani pipeline’u — to **decyzja dydaktyczna** tego laba.

## Walidacja

```bash
terraform output -raw config_url
curl -i "$(terraform output -raw config_url)"
```

## Cleanup

```bash
terraform destroy
```

Sekret ma w IaC ustawione `recovery_window_in_days = 0` (brak typowego okna odzyskiwania przy usuwaniu — patrz wyjaśnienie w runbooku `docs/labs/runs/LAB-003.md`, sekcja *Usuwanie sekretu w tym labie*). **Nie** kopiuj tego wzorca bez przemyślenia do produkcji.
