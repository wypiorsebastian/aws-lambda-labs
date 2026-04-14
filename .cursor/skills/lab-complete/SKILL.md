---
name: lab-complete
description: Kończy wskazany lab, ocenia go deklaratywnie na podstawie checklisty, zapisuje wnioski i aktualizuje tracker postępu. Użyj gdy użytkownik wpisuje /lab-complete LAB-XXX.
disable-model-invocation: true
---
# Lab Complete

Uruchamiaj tę skill wyłącznie jawnie, np. `/lab-complete LAB-007`.

## Cel
Zamknąć pracę nad labem tylko wtedy, gdy użytkownik deklaratywnie potwierdzi wykonanie checklisty albo świadomie zaakceptuje brakujące elementy.

## Źródła prawdy
- `docs/labs/runs/<LAB-ID>.md`
- `docs/labs/progress.md`
- `assets/completion-template.md`

## Co masz zrobić
1. Odczytaj ID laba z promptu.
2. Otwórz `docs/labs/runs/<LAB-ID>.md`.
3. Sprawdź, czy runbook zawiera checklistę i sekcję cleanup.
4. Poproś użytkownika o deklaratywne potwierdzenie wykonania lub wskaż brakujące elementy, jeśli są oczywiste.
5. Jeżeli uznasz lab za ukończony:
   - dopisz krótkie `Notes`
   - dopisz `Decisions`, `Problems`, `Cleanup`, `Learned` do `docs/labs/progress.md`
   - ustaw status `DONE`
6. Jeżeli lab nie jest ukończony:
   - nie ustawiaj `DONE`
   - wypisz brakujące elementy
   - pozostaw `IN_PROGRESS`
7. Na końcu przypomnij użytkownikowi, co zrobić z infrastrukturą: zachować ją do kolejnego laba, czy zniszczyć przez Terraform destroy.

## Zasada oceny
- Walidacja jest deklaratywna, nie rygorystycznie automatyczna.
- Jeżeli użytkownik mówi, że coś świadomie pominął, zaznacz to w notatkach.

## Operacje techniczne
Do aktualizacji statusu użyj:
`python .cursor/skills/lab-start/scripts/lab_manager.py complete <LAB-ID> "krótka-notatka"`

## Odpowiedź końcowa do użytkownika
- status: `DONE` albo `IN_PROGRESS`
- co uznałeś za ukończone
- co ewentualnie zostało pominięte
- rekomendowany cleanup
- proponowany następny lab
