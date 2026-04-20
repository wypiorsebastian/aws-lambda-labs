# LAB-004 — Terraform (HTTP API + JWT + Cognito)

## Co robi ten szkielet

- Tworzy **Amazon Cognito User Pool** i **publicznego** klienta aplikacji z przepływem `USER_PASSWORD_AUTH` (tylko do nauki).
- Wystawia **HTTP API** z:
  - `GET /public` — bez autoryzacji JWT,
  - `GET /claims` — z **wbudowanym JWT authorizerem** (issuer Cognito, audience = client id),
  - prostą konfiguracją **CORS** (`Simplification for this lab`: szerokie originy).

## Zanim uruchomisz

1. Zbuduj ZIP funkcji zgodnie z `docs/labs/runs/LAB-004.md`.
2. Upewnij się, że istnieje plik `artifacts/LAB-004/function.zip` (względem root repo).

## Typowe komendy

```bash
terraform init
terraform apply
terraform output
```

## TODO(lab-004) — rozszerzenia (nieblokujące)

- **Custom domain** + ACM + rekord DNS — poza zakresem tego szkieletu; zobacz runbook.
- **Zawężenie CORS** do konkretnego originu SPA.
- **Hosted UI** Cognito zamiast samego `InitiateAuth` — osobny przepływ OAuth/OIDC.

## Cleanup

```bash
terraform destroy
```
