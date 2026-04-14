#!/usr/bin/env python3
from __future__ import annotations
import re
import sys
from pathlib import Path
from datetime import date

ROOT = Path(__file__).resolve().parents[4]
PROGRESS = ROOT / 'docs/labs/progress.md'
RUNS_DIR = ROOT / 'docs/labs/runs'
TF_DIR = ROOT / 'infra/terraform/labs'


def read_text(p: Path) -> str:
    return p.read_text(encoding='utf-8')


def write_text(p: Path, text: str) -> None:
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding='utf-8')


def update_summary(text: str) -> str:
    rows = re.findall(r'^\| (LAB-\d{3}) \| .*? \| (NOT_STARTED|IN_PROGRESS|DONE) \|', text, re.M)
    total = len(rows)
    done = sum(1 for _, s in rows if s == 'DONE')
    in_progress = sum(1 for _, s in rows if s == 'IN_PROGRESS')
    not_started = sum(1 for _, s in rows if s == 'NOT_STARTED')
    text = re.sub(r'- Total labs: \d+', f'- Total labs: {total}', text)
    text = re.sub(r'- Done: \d+', f'- Done: {done}', text)
    text = re.sub(r'- In progress: \d+', f'- In progress: {in_progress}', text)
    text = re.sub(r'- Not started: \d+', f'- Not started: {not_started}', text)
    return text


def start_lab(lab_id: str) -> None:
    text = read_text(PROGRESS)
    today = str(date.today())
    pattern = rf'^(\| {re.escape(lab_id)} \| .*? \| )([^|]+)( \| )([^|]+)( \| )([^|]+)( \| )([^|]+)( \|)$'
    def repl(m):
        return f"{m.group(1)}IN_PROGRESS{m.group(3)}{today}{m.group(5)}-{m.group(7)}-{m.group(9)}"
    text, count = re.subn(pattern, repl, text, flags=re.M)
    if count == 0:
        raise SystemExit(f'Nie znaleziono wiersza dla {lab_id}')
    section_pattern = rf'(### {re.escape(lab_id)}\n)(- Decisions: ).*?(\n- Problems: ).*?(\n- Cleanup: ).*?(\n- Learned:\n)(?:  - .*?\n)+'
    def sec_repl(m):
        return f"{m.group(1)}{m.group(2)}-\n{m.group(3)}-\n{m.group(4)}-\n{m.group(5)}  - -\n"
    text = re.sub(section_pattern, sec_repl, text, flags=re.S)
    text = update_summary(text)
    write_text(PROGRESS, text)

    tf_lab = TF_DIR / lab_id
    tf_lab.mkdir(parents=True, exist_ok=True)
    skeletons = {
        'main.tf': f'# Terraform skeleton for {lab_id}\n\nterraform {{\n  required_version = ">= 1.6.0"\n  required_providers {{\n    aws = {{\n      source  = "hashicorp/aws"\n      version = "~> 6.0"\n    }}\n  }}\n}}\n\nprovider "aws" {{\n  region = var.aws_region\n}}\n\n# TODO: uzupełnij zasoby dla {lab_id}\n',
        'variables.tf': 'variable "aws_region" {\n  type        = string\n  description = "AWS region for the lab"\n  default     = "eu-central-1"\n}\n',
        'outputs.tf': '# TODO: dodaj outputy przydatne do walidacji laba\n',
        'README.md': f'# {lab_id} Terraform skeleton\n\nTen katalog zawiera tylko szkielet IaC dla laba {lab_id}.\n\n## Zasady\n- rozwijaj go iteracyjnie\n- po labie przewiduj destroy/cleanup\n'
    }
    for name, content in skeletons.items():
        p = tf_lab / name
        if not p.exists():
            write_text(p, content)


def complete_lab(lab_id: str, notes: str = 'Ukończono deklaratywnie na podstawie checklisty.') -> None:
    text = read_text(PROGRESS)
    today = str(date.today())
    pattern = rf'^(\| {re.escape(lab_id)} \| .*? \| )([^|]+)( \| )([^|]+)( \| )([^|]+)( \| )([^|]+)( \|)$'
    def repl(m):
        current_started = m.group(4).strip() if m.group(4).strip() != '-' else today
        return f"{m.group(1)}DONE{m.group(3)}{current_started}{m.group(5)}{today}{m.group(7)}{notes}{m.group(9)}"
    text, count = re.subn(pattern, repl, text, flags=re.M)
    if count == 0:
        raise SystemExit(f'Nie znaleziono wiersza dla {lab_id}')
    text = update_summary(text)
    write_text(PROGRESS, text)


def status(lab_id: str | None = None) -> None:
    text = read_text(PROGRESS)
    if lab_id:
        for line in text.splitlines():
            if line.startswith(f'| {lab_id} |'):
                print(line)
                return
        raise SystemExit(f'Nie znaleziono {lab_id}')
    print(text)


def main(argv: list[str]) -> None:
    if len(argv) < 2:
        raise SystemExit('Użycie: lab_manager.py <start|complete|status> <LAB-ID> [notes]')
    cmd = argv[1]
    if cmd == 'status':
        status(argv[2] if len(argv) > 2 else None)
        return
    if len(argv) < 3:
        raise SystemExit('Brak LAB-ID')
    lab_id = argv[2].strip().upper()
    if not re.fullmatch(r'LAB-\d{3}', lab_id):
        raise SystemExit(f'Niepoprawny format ID: {lab_id}')
    if cmd == 'start':
        start_lab(lab_id)
    elif cmd == 'complete':
        notes = argv[3] if len(argv) > 3 else 'Ukończono deklaratywnie na podstawie checklisty.'
        complete_lab(lab_id, notes)
    else:
        raise SystemExit(f'Nieznana komenda: {cmd}')


if __name__ == '__main__':
    main(sys.argv)
