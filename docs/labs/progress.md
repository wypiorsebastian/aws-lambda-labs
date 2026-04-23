# Progress tracker — AWS Lambda + API Gateway labs

> Ten plik jest jedynym źródłem prawdy o postępie.

## Summary

- Total labs: 22
- Done: 4
- In progress: 3
- Not started: 15

## Labs

<!-- PROGRESS_TABLE_START -->
| Lab | Title | Status | Started | Completed | Notes |
|---|---|---|---|---|---|
| LAB-001 | Publiczny endpoint dla zespołu statusowego | IN_PROGRESS | 2026-04-14 | - | - |
| LAB-002 | Jedna funkcja, wiele tras | DONE | 2026-04-15 | 2026-04-16 | Jedna Lambda, wiele tras HTTP API; payload 2.0; wdrożenie ZIP + apply; routing i logi zweryfikowane w praktyce. |
| LAB-003 | Konfiguracja środowisk i tajemnic | IN_PROGRESS | 2026-04-16 | - | - |
| LAB-004 | JWT dla publicznego API | IN_PROGRESS | 2026-04-17 | - | - |
| LAB-005 | Własny Lambda authorizer | DONE | 2026-04-20 | 2026-04-20 | HTTP API, REQUEST authorizer, payload 2.0 i simple responses; .NET z camelCase w JSON odpowiedzi authorizera; dwa ZIP (linux-x64) i walidacja curl. |
| LAB-006 | Observability dla publicznego API | DONE | 2026-04-21 | 2026-04-21 | HTTP API access logs + Lambda Active X-Ray + Powertools .NET 3 (logging/metrics/tracing); trasy /health /orders/{id} /fail; artefakt linux-x64 ZIP. |
| LAB-007 | Wersje, aliasy i bezpieczny release funkcji | NOT_STARTED | - | - | - |
| LAB-008 | Skalowanie i kontrola kosztu | NOT_STARTED | - | - | - |
| LAB-009 | Container image dla Lambdy | DONE | 2026-04-22 | 2026-04-23 | Lambda image (.NET 8) na ECR + HTTP API; diagnostyka i naprawa błędu unsupported media type przez build bez provenance/sbom. |
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
- Decisions: HTTP API z trasami `GET /public` (bez autoryzacji) i `GET /profile` (`authorization_type = CUSTOM`, REQUEST authorizer); jedna integracja `AWS_PROXY` (payload 2.0) do Lambdy biznesowej; authorizer z `authorizer_payload_format_version = 2.0`, `enable_simple_responses = true`, `identity_sources = [$request.header.Authorization]`; `authorizer_result_ttl_in_seconds = 0` na czas nauki; token testowy na sztywno w kodzie authorizera (`Bearer lab005-allow`) jako uproszczenie dydaktyczne.

- Problems: Błąd **500** z API Gateway przy poprawnym i błędnym tokenie — odpowiedź authorizera w JSON z polami PascalCase (`IsAuthorized`) zamiast wymaganego `isAuthorized` (simple response, payload 2.0); naprawa przez `[JsonPropertyName("isAuthorized")]` / `context` oraz dopięcie deserializacji wejścia (`routeKey`, `headers`).

- Cleanup: `cd infra/terraform/labs/LAB-005 && terraform destroy`; opcjonalnie usunąć lokalnie `artifacts/LAB-005/*.zip`.

- Learned:
  - Kolejność **authorizer → backend** wyznacza API Gateway wg konfiguracji trasy, nie Lambda biznesowa.
  - Dla HTTP API Lambda authorizer (payload 2.0, simple responses) format odpowiedzi musi być zgodny z dokumentacją AWS (m.in. camelCase); zły format lub brak `lambda:InvokeFunction` dla authorizera kończy się **500**.
  - Przy `identity_sources` brak wymaganego nagłówka zwykle daje **401** bez wywołania authorizera.

### LAB-006
- Decisions: HTTP API (`$default` stage) z integracją `AWS_PROXY` (payload 2.0) do jednej Lambdy `dotnet8` (`x86_64`); access logging na stage do dedykowanej grupy CloudWatch (format JSON z polami diagnostycznymi); `tracing_config.mode = Active` + `AWSXRayDaemonWriteAccess`; Powertools for AWS Lambda (.NET) 3.x (`Logging`, `Metrics`, `Tracing`) w handlerze; trasy testowe `GET /health`, `GET /orders/{orderId}`, `GET /fail`.

- Problems: Przy pierwszym buildzie NuGet nie miał wersji Powertools `2.2.0` — rozwiązanie przez jawne `3.0.0` oraz usunięcie przestarzałego `using AWS.Lambda.Powertools.Metrics.Capture`.

- Cleanup: `cd infra/terraform/labs/LAB-006 && terraform destroy`; opcjonalnie usuń lokalnie `artifacts/LAB-006/function.zip`.

- Learned:
  - Access logs API Gateway dają widok request/response na krawędzi API; logi Lambdy pokazują kod — razem łatwiej rozdzielić błąd integracji od błędu handlera.
  - X-Ray dla Lambda używa próbkowania; do diagnozy warto wykonać kilka requestów i patrzeć na segmenty `AWS::Lambda` vs `AWS::Lambda::Function`.
  - Powertools ułatwia spójne structured logging i metryki EMF bez ręcznego składania formatów.

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
- Decisions: Jeden spójny wariant: Lambda `package_type = Image` (.NET 8, `x86_64`) + ECR + HTTP API (`GET /health`, payload 2.0, stage `$default`); Terraform tworzy ECR/Lambda/API, a build+push obrazu jest krokiem osobnym; `image_tag` sterowany przez `terraform.tfvars`.

- Problems: `InvalidParameterValueException` przy `CreateFunction` (unsupported media type manifestu obrazu) po pushu obrazu z domyślnymi attestacjami BuildKit; rozwiązanie: przebudowa i push z `--provenance=false --sbom=false` (ew. `BUILDX_NO_DEFAULT_ATTESTATIONS=1`) oraz ponowny `terraform apply`.

- Cleanup: `cd infra/terraform/labs/LAB-009 && terraform destroy`; opcjonalnie usuń lokalne obrazy Dockera (`docker image rm ...`) i nieużywane tagi w ECR po zakończeniu ćwiczenia.

- Learned:
  - `-target` w Terraform służył tu tylko do utworzenia ECR przed pierwszym push; pełny apply jest potrzebny później do domknięcia całego stosu.
  - Dla Lambdy image-based krytyczna jest zgodność `image_uri` (`repo:tag`) między ECR i `var.image_tag`.
  - Nowszy Docker/BuildKit może generować manifesty nieakceptowane przez Lambda; warto jawnie kontrolować opcje builda.
  - Podstawowa walidacja to `curl` na `health_url` + logi CloudWatch funkcji.

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
