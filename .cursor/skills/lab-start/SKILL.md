---
name: lab-start
description: Startuje wskazany lab AWS Lambda + API Gateway, generuje treść scenariusza, tworzy runbook laba i przygotowuje szkielet Terraform. Użyj gdy użytkownik wpisuje /lab-start LAB-XXX.
disable-model-invocation: true
---
# Lab Start

Uruchamiaj tę skill wyłącznie jawnie, np. `/lab-start LAB-007`.

## Cel
Na podstawie ID laba z katalogu labów wygeneruj konkretną instancję materiału do wykonania.

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
4. Wygeneruj plik `docs/labs/runs/<LAB-ID>.md` na podstawie szablonu.
5. Wygenerowany runbook ma zawierać:
   - tytuł i ID
   - story / business background
   - czego użytkownik się nauczy
   - założenia
   - architektoniczny szkic rozwiązania
   - checklistę krok po kroku
   - sekcję Terraform / IaC ze szkieletem do uzupełnienia
   - walidację
   - pułapki
   - cleanup
   - źródła oficjalne
6. Przygotuj szkielet Terraform w `infra/terraform/labs/<LAB-ID>/`.
7. Zaktualizuj `docs/labs/progress.md` na status `IN_PROGRESS`.
8. Na końcu odpowiedzi do użytkownika pokaż:
   - które pliki zostały utworzone lub zaktualizowane
   - od czego zacząć ręcznie
   - jakie są 2–4 główne ryzyka lub pułapki dla tego laba

## Zasady jakości
- Nie generuj gotowego, pełnego rozwiązania end-to-end. To ma być lab, nie gotowiec.
- Terraform ma być szkieletem, a nie finalnym produkcyjnym wdrożeniem.
- Instrukcje mają prowadzić użytkownika po kolei.
- W labie jawnie zaznacz granicę między tym, co użytkownik ma zrobić sam, a tym, co jest przykładowym szkieletem.

## Operacje techniczne
Do aktualizacji trackera użyj:
`python .cursor/skills/lab-start/scripts/lab_manager.py start <LAB-ID>`

Do wygenerowania podstawowego szkieletu katalogów możesz utworzyć:
- `infra/terraform/labs/<LAB-ID>/main.tf`
- `infra/terraform/labs/<LAB-ID>/variables.tf`
- `infra/terraform/labs/<LAB-ID>/outputs.tf`
- `infra/terraform/labs/<LAB-ID>/README.md`

## Gdy lab już jest w toku
- Nie nadpisuj bez pytania treści, jeśli `docs/labs/runs/<LAB-ID>.md` już istnieje.
- Zamiast tego zaproponuj wznowienie pracy i ewentualne dopisanie brakujących sekcji.
