# Katalog labów — AWS Lambda + API Gateway + .NET 8/10

Poniżej jest pełna, liniowa sekwencja labów. Każdy lab ma formę realistycznego scenariusza. Razem pokrywają modele uruchomienia Lambdy, HTTP API, REST API, security, observability, release, private access i Terraform.

## LAB-001 — Publiczny endpoint dla zespołu statusowego
**Story:** zespół operacyjny chce wystawić bardzo prosty endpoint `/health` dla wewnętrznego mikroserwisu raportowego, ale bez stawiania całego serwera.

**Zakres:**
- Lambda w .NET 8 jako managed runtime
- zip deployment
- podstawy handlera C#
- HTTP API jako najprostszy front door
- request flow klient -> API Gateway -> Lambda
- minimalny Terraform skeleton

**Artefakty:**
- `docs/labs/runs/LAB-001.md`
- `infra/terraform/labs/LAB-001/`

---

## LAB-002 — Jedna funkcja, wiele tras
**Story:** zespół chce szybko wystawić małe CRUD-like API dla katalogu feature flags.

**Zakres:**
- HTTP API routes
- `ANY` i `$default`
- payload format i mapowanie eventu do .NET
- query/path/body parsing
- lepsza organizacja kodu Lambdy

---

## LAB-003 — Konfiguracja środowisk i tajemnic
**Story:** aplikacja ma rozdzielone środowiska dev/test i potrzebuje bezpiecznej konfiguracji.

**Zakres:**
- environment variables
- version-specific configuration
- KMS encryption basics
- kiedy użyć Secrets Manager zamiast env vars
- execution role basics

---

## LAB-004 — JWT dla publicznego API
**Story:** API ma być dostępne publicznie, ale tylko dla klientów z poprawnym tokenem OIDC/JWT.

**Zakres:**
- HTTP API JWT authorizer
- claims propagation
- CORS
- custom domain basics
- testowanie autoryzacji

---

## LAB-005 — Własny Lambda authorizer
**Story:** firma ma niestandardowe reguły dostępu zależne od tenantów i planów subskrypcyjnych.

**Zakres:**
- Lambda authorizer dla HTTP API
- payload 1.0 vs 2.0 dla authorizerów
- custom auth decision flow
- separacja authorizer / business Lambda

---

## LAB-006 — Observability dla publicznego API
**Story:** zespół widzi sporadyczne 5xx i rosnące opóźnienia, ale nie ma diagnostyki end-to-end.

**Zakres:**
- CloudWatch logs i metryki
- X-Ray dla Lambda
- Powertools for AWS Lambda (.NET)
- structured logging
- walidacja cold start vs invoke path

---

## LAB-007 — Wersje, aliasy i bezpieczny release funkcji
**Story:** nowa wersja logiki billingowej musi wejść na ruch stopniowo, z możliwością natychmiastowego rollbacku.

**Zakres:**
- Lambda versions
- aliases
- weighted alias routing
- release strategy na poziomie funkcji
- relacja alias vs API Gateway integration target

---

## LAB-008 — Skalowanie i kontrola kosztu
**Story:** endpoint promocyjny może zostać nagle zalany ruchem po kampanii marketingowej.

**Zakres:**
- concurrency model
- reserved concurrency
- provisioned concurrency
- throttling side effects
- interpretacja metryk wydajnościowych

---

## LAB-009 — Container image dla Lambdy
**Story:** zespół chce mieć większą kontrolę nad środowiskiem wykonania i build pipeline.

**Zakres:**
- package type image
- ECR
- AWS base image vs OS-only vs alternative image
- local build workflow
- plusy i minusy obrazów kontenerowych

---

## LAB-010 — Custom runtime
**Story:** zespół platformowy chce zrozumieć mechanikę Lambdy pod maską, a nie tylko używać managed runtime.

**Zakres:**
- Runtime API
- bootstrap
- custom runtime packaging
- kiedy custom runtime ma sens
- ograniczenia i koszty złożoności

---

## LAB-011 — Native AOT w .NET 8
**Story:** API onboardingowe ma bardzo niski ruch, ale każda pierwsza odpowiedź musi być szybka.

**Zakres:**
- Native AOT
- trimming
- reflection pitfalls
- cold start trade-offs
- ograniczenia bibliotek i serializacji

---

## LAB-012 — Response streaming
**Story:** klient chce zacząć odbierać części odpowiedzi wcześniej, zanim cały payload zostanie zbudowany.

**Zakres:**
- Lambda response streaming
- API Gateway response transfer mode
- buffered vs streaming response
- dobór scenariusza użycia

---

## LAB-013 — Kiedy HTTP API nie wystarcza
**Story:** pojawia się potrzeba planów taryfowych, limitów per klient i walidacji requestów jeszcze przed backendem.

**Zakres:**
- świadome przejście z HTTP API na REST API
- porównanie funkcji i ceny
- decyzja architektoniczna HTTP API vs REST API

---

## LAB-014 — REST API z walidacją requestów
**Story:** publiczne API dla partnerów ma odrzucać złe requesty zanim dotrą do kodu biznesowego.

**Zakres:**
- REST API resources/methods
- request validation
- gateway responses
- CORS dla REST API
- stages i deployments

---

## LAB-015 — API keys, usage plans i throttling
**Story:** partnerzy B2B mają różne plany taryfowe i różne limity ruchu.

**Zakres:**
- API keys
- usage plans
- per-client throttling
- quota semantics i ich ograniczenia
- monitoring nadużyć

---

## LAB-016 — WAF i hardening publicznego REST API
**Story:** endpoint publiczny zaczyna dostawać dziwne requesty i trzeba go utwardzić.

**Zakres:**
- WAF z REST API
- endpoint types
- logging na poziomie gatewaya
- resource policies basics
- custom domain + mappings

---

## LAB-017 — Canary release po stronie API Gateway
**Story:** zespół chce testować nowy deployment API na małym procencie ruchu niezależnie od wersjonowania samej funkcji.

**Zakres:**
- stage settings
- canary release dla REST API
- promotion / rollback
- porównanie canary w gateway vs weighted alias w Lambda

---

## LAB-018 — Lambda w VPC i dostęp do zasobów prywatnych
**Story:** funkcja musi łączyć się z prywatnym zasobem, więc wymaga świadomej konfiguracji sieciowej.

**Zakres:**
- Lambda VPC attachment
- execution environment networking
- internet access z VPC-connected Lambda
- NAT i subnet design
- security trade-offs

---

## LAB-019 — EFS, parametry i sekrety
**Story:** funkcja wymaga współdzielonego filesystemu i bezpiecznego odczytu parametrów w runtime.

**Zakres:**
- EFS z Lambda
- Parameters and Secrets Lambda Extension
- cache secretów i parametrów
- wpływ na init i runtime behavior

---

## LAB-020 — Private REST API
**Story:** wewnętrzny zespół chce udostępnić API tylko z prywatnej sieci, bez publicznego endpointu.

**Zakres:**
- private REST API
- interface VPC endpoint
- resource policies dla private API
- ograniczenia private APIs

---

## LAB-021 — HTTP API private integrations i VPC Link
**Story:** API ma być publiczne, ale backend ma pozostać prywatny i działać w VPC.

**Zakres:**
- HTTP API private integrations
- VPC Link
- kiedy API Gateway integruje się z backendem prywatnym zamiast Lambdy
- public entrypoint + private backend pattern

---

## LAB-022 — Finał: production-like mini platform
**Story:** tworzysz mini-platformę API dla zespołu produktowego: publiczne HTTP API, zaawansowane REST API dla partnerów, obserwowalność, release control i cleanup hygiene.

**Zakres:**
- spójne połączenie tematów
- wybór właściwego typu API dla konkretnych use case'ów
- release strategy
- security baseline
- cost hygiene
- końcowe podsumowanie wiedzy
