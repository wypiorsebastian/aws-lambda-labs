---
name: lab-status
description: Pokazuje status całego programu labów albo pojedynczego laba na podstawie docs/labs/progress.md. Użyj np. /lab-status lub /lab-status LAB-007.
disable-model-invocation: true
---
# Lab Status

## Cel
Szybko odczytać stan postępu bez ręcznego przeglądania pliku markdown.

## Co masz zrobić
1. Jeżeli podano LAB-ID, pokaż tylko ten wpis.
2. Jeżeli nie podano ID, pokaż podsumowanie i najbliższy sensowny kolejny lab.
3. Dane czytaj wyłącznie z `docs/labs/progress.md`.

## Operacja techniczna
Użyj:
`python .cursor/skills/lab-start/scripts/lab_manager.py status`
lub
`python .cursor/skills/lab-start/scripts/lab_manager.py status <LAB-ID>`
