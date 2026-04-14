---
name: lab-start
description: Startuje wskazany lab AWS Lambda + API Gateway, generuje runbook laba i przygotowuje pół-wykonawczy szkielet Terraform. Użyj gdy użytkownik wpisuje /lab-start LAB-XXX.
disable-model-invocation: true
---

# Lab Start

Uruchamiaj tę skill wyłącznie jawnie, np. `/lab-start LAB-007`.

## Cel
Na podstawie ID laba z katalogu labów wygeneruj spójny technicznie materiał do wykonania: runbook i szkielet IaC.

## Wejście
- Argument po nazwie skilla zawiera ID, np. `LAB-007`.

## Źródła prawdy
- `docs/labs/catalog.md`
- `docs/labs/progress.md`
- `@AGENTS.md`
- `@.cursor/rules/00-official-sources-only.mdc`
- `references/aws-reference-map.md`
- `assets/runbook-template.md`

## Co masz zrobić
1. Odczytaj ID laba z promptu.
2. Otwórz `docs/labs/catalog.md` i znajdź sekcję dla wskazanego ID.
3. Zbierz tylko oficjalne źródła AWS i Cursor potrzebne do tego laba.
4. Zanim zaczniesz pisać pliki, ustal jeden konkretny wariant techniczny dla tego laba.
5. Wygeneruj plik `docs/labs/runs/<LAB-ID>.md` na podstawie szablonu.
6. Przygotuj pół-wykonawczy szkielet Terraform w `infra/terraform/labs/<LAB-ID>/`.
7. Zaktualizuj `docs/labs/progress.md` na status `IN_PROGRESS`.
8. Wykonaj audyt spójności technicznej przed zakończeniem.
9. Na końcu odpowiedzi pokaż:
   - które pliki zostały utworzone lub zaktualizowane
   - od czego zacząć ręcznie
   - główne ryzyka i pułapki

## Obowiązkowa struktura runbooka
Runbook musi zawierać:
- tytuł i ID
- story / business background
- czego użytkownik się nauczy
- założenia
- decyzje architektoniczne
- architektoniczny szkic rozwiązania
- checklistę krok po kroku
- sekcję Terraform / IaC
- walidację
- pułapki
- cleanup
- źródła oficjalne

## Zasady jakości
- Nie generuj gotowego pełnego rozwiązania end-to-end.
- Terraform ma być szkieletem pół-wykonawczym, nie pustym placeholderem.
- Każde miejsce do samodzielnego uzupełnienia musi być jawnie oznaczone.
- Nie mieszaj wielu wariantów rozwiązania w jednym labie.
- Jawnie oznaczaj:
  - wymagania platformy
  - decyzje projektowe dla tego laba
  - best practices
  - uproszczenia dydaktyczne
- Wszystkie domyślne założenia krytyczne dla wykonania muszą być zapisane jawnie.

## Audyt końcowy
Przed zapisaniem plików sprawdź:
- zgodność opisu z kodem
- zgodność opisu z Terraform
- zgodność walidacji z wygenerowanymi artefaktami
- zgodność cleanup z ownership zasobów
- zgodność URL-i, route’ów, stage’y, payload formatów i permissions

Jeśli wykryjesz niespójność, popraw ją przed zapisaniem plików.

## Operacje techniczne
Do aktualizacji trackera użyj:
`python .cursor/skills/lab-start/scripts/lab_manager.py start <LAB-ID>`

Możesz utworzyć:
- `infra/terraform/labs/<LAB-ID>/main.tf`
- `infra/terraform/labs/<LAB-ID>/variables.tf`
- `infra/terraform/labs/<LAB-ID>/outputs.tf`
- `infra/terraform/labs/<LAB-ID>/README.md`

## Gdy lab już jest w toku
- Nie nadpisuj bez pytania treści, jeśli `docs/labs/runs/<LAB-ID>.md` już istnieje.
- Zamiast tego zaproponuj wznowienie pracy i dopisanie brakujących sekcji.