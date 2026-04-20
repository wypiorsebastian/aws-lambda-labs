# Progress tracker — AWS Lambda + API Gateway labs

> Ten plik jest jedynym źródłem prawdy o postępie.

## Summary

- Total labs: 22
- Done: 1
- In progress: 3
- Not started: 18

## Labs

<!-- PROGRESS_TABLE_START -->
| Lab | Title | Status | Started | Completed | Notes |
|---|---|---|---|---|---|
| LAB-001 | Publiczny endpoint dla zespołu statusowego | IN_PROGRESS | 2026-04-14 | - | - |
| LAB-002 | Jedna funkcja, wiele tras | DONE | 2026-04-15 | 2026-04-16 | Jedna Lambda, wiele tras HTTP API; payload 2.0; wdrożenie ZIP + apply; routing i logi zweryfikowane w praktyce. |
| LAB-003 | Konfiguracja środowisk i tajemnic | IN_PROGRESS | 2026-04-16 | - | - |
| LAB-004 | JWT dla publicznego API | IN_PROGRESS | 2026-04-17 | - | - |
| LAB-005 | Własny Lambda authorizer | NOT_STARTED | - | - | - |
| LAB-006 | Observability dla publicznego API | NOT_STARTED | - | - | - |
| LAB-007 | Wersje, aliasy i bezpieczny release funkcji | NOT_STARTED | - | - | - |
| LAB-008 | Skalowanie i kontrola kosztu | NOT_STARTED | - | - | - |
| LAB-009 | Container image dla Lambdy | NOT_STARTED | - | - | - |
| LAB-010 | Custom runtime | NOT_STARTED | - | - | - |
| LAB-011 | Native AOT w .NET 8 | NOT_STARTED | - | - | - |
| LAB-012 | Response streaming | NOT_STARTED | - | - | - |
| LAB-013 | Kiedy HTTP API nie wystarcza | NOT_STARTED | - | - | - |
| LAB-014 | REST API z walidacją requestów | NOT_STARTED | - | - | - |
| LAB-015 | API keys, usage plans i throttling | NOT_STARTED | - | - | - |
| LAB-016 | WAF i hardening publicznego REST API | NOT_STARTED | - | - | - |
| LAB-017 | Canary release po stronie API Gateway | NOT_STARTED | - | - | - |
| LAB-018 | Lambda w VPC i dostęp do zasobów prywatnych | NOT_STARTED | - | - | - |
| LAB-019 | EFS, parametry i sekrety | NOT_STARTED | - | - | - |
| LAB-020 | Private REST API | NOT_STARTED | - | - | - |
| LAB-021 | HTTP API private integrations i VPC Link | NOT_STARTED | - | - | - |
| LAB-022 | Finał: production-like mini platform | NOT_STARTED | - | - | - |
<!-- PROGRESS_TABLE_END -->

## Detailed notes

<!-- DETAILED_NOTES_START -->
### LAB-001
- Decisions: -

- Problems: -

- Cleanup: -

- Learned:
  - -

### LAB-002
- Decisions: HTTP API z kilkoma route'ami (`GET`/`POST` `/flags`, `ANY /flags/{flagKey}`, `$default`) i jedną integracją Lambda proxy; payload format 2.0; stage `$default` i route `$default` jako osobne pojęcia; brak trwałej persystencji (cel laba: transport i dispatch).

- Problems: Wyjątki w handlerze (np. szkielet z `NotImplementedException`) dawały 5xx po stronie API Gateway; dopasowanie runtime `dotnet8` do `TargetFramework` net8.0 w projekcie; dopasowanie `source_arn` permission do HTTP API (`/*/*`).

- Cleanup: `cd infra/terraform/labs/LAB-002 && terraform destroy`; opcjonalnie usunąć lokalny `artifacts/LAB-002/function.zip` jeśli nie chcesz trzymać artefaktu.

- Learned:
  - Routing wybiera API Gateway — w Lambdzie rozgałęziasz po `routeKey` i metodzie HTTP, nie „na ślepo” po samym path.
  - `ANY` i `$default` mają konkretne role; `POST /flags` wymaga osobnej trasy, nie wystarczy `ANY /flags/{flagKey}`.
  - Błąd w funkcji to zwykle błąd dla klienta HTTP — walidacja kończy się `curl` + CloudWatch.
  - Logi idą przez execution role do CloudWatch — nie trzeba „logowania” do CloudWatch z kodu poza `context.Logger` / standardowym logowaniem.

### LAB-003
- Decisions: -

- Problems: -

- Cleanup: -

- Learned:
  - -

### LAB-004
- Decisions: -

- Problems: -

- Cleanup: -

- Learned:
  - -

### LAB-005
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-006
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-007
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-008
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-009
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-010
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-011
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-012
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-013
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-014
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-015
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-016
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-017
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-018
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-019
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-020
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-021
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -

### LAB-022
- Decisions: -
- Problems: -
- Cleanup: -
- Learned:
  - -
<!-- DETAILED_NOTES_END -->
