# AWS Lambda + API Gateway + .NET 8/10 Labs for Cursor

Ten starter pack organizuje naukę w postaci scenariuszowych labów realizowanych z pomocą Cursor Agent.

## Główna idea

- uruchamiasz lab przez `/lab-start LAB-XXX`
- Cursor generuje treść konkretnego laba na podstawie katalogu labów i zapisuje ją do `docs/labs/runs/LAB-XXX.md`
- Cursor przygotowuje szkielet IaC w `infra/terraform/labs/LAB-XXX/`
- kończysz lab przez `/lab-complete LAB-XXX`
- Cursor aktualizuje `docs/labs/progress.md`, dopisuje wnioski, cleanup i status

## Struktura

- `.cursor/rules/` — trwałe reguły dla agenta
- `.cursor/skills/` — jawnie wywoływane workflowy typu slash-like skills
- `docs/labs/catalog.md` — sekwencja wszystkich labów i ich zakres
- `docs/labs/progress.md` — tracker postępu w Markdown
- `docs/labs/runs/` — wygenerowane instancje labów
- `infra/terraform/labs/` — szkielety Terraform per lab

## Zalecany sposób pracy

1. Otwórz repo w Cursor.
2. Przejrzyj `docs/labs/catalog.md`.
3. Uruchom `/lab-start LAB-001`.
4. Realizuj lab krok po kroku. Nie proś agenta o wykonanie wszystkiego naraz — agent ma prowadzić, a nie wyręczać.
5. Po skończeniu uruchom `/lab-complete LAB-001`.
6. Przed przejściem dalej sprawdź `docs/labs/progress.md`.

## Uwaga praktyczna

W Cursor skills mogą działać jak jawnie wywoływane komendy. Dlatego workflow opiera się na skills z `disable-model-invocation: true`, a nie na luźnych promptach w czacie.
