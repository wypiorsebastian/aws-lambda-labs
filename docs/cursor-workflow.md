# Cursor workflow dla labów

## Dlaczego skills, a nie zwykłe promptowanie

Ten projekt używa skills jako jawnie wywoływanych workflowów. Dzięki `disable-model-invocation: true` skill zachowuje się jak klasyczna komenda wywoływana explicite.

## Komendy do użycia w Agent chat

- `/lab-start LAB-001`
- `/lab-complete LAB-001`
- `/lab-status`
- `/lab-status LAB-001`

## Oczekiwany flow

1. Wybierz lab z `docs/labs/catalog.md`.
2. Wpisz `/lab-start LAB-XXX`.
3. Cursor wygeneruje `docs/labs/runs/LAB-XXX.md` i szkielet Terraform.
4. Realizuj lab iteracyjnie.
5. Gdy skończysz, wpisz `/lab-complete LAB-XXX`.
6. Sprawdź `docs/labs/progress.md`.

## Uwaga

Jeśli w Twojej konfiguracji Cursor slash-like wywołanie skilli okaże się niewygodne, możesz osiągnąć identyczny efekt przez ręczne wywołanie skillu z listy `/` i dopisanie ID laba w tej samej wiadomości.
