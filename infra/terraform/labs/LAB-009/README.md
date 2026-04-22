# LAB-009 — Terraform (Lambda container image + HTTP API)

## Co robi ten szkielet

- Tworzy repozytorium ECR `lab009-lambda-image`.
- Tworzy funkcję Lambda z `package_type = "Image"`.
- Tworzy HTTP API z trasą `GET /health` i stage `$default`.
- Dodaje uprawnienie `lambda:InvokeFunction` dla API Gateway.
- Tworzy grupę logów CloudWatch dla Lambdy.

## Zanim uruchomisz

1. Przygotuj kod i `Dockerfile` dla funkcji z `src/LAB-009/...`.
2. Zbuduj obraz lokalnie (ważne na nowszych Dockerach: wyłącz attestacje BuildKita, inaczej Lambda potrafi odrzucić manifest obrazu):
   ```bash
   docker build \
     --platform linux/amd64 \
     --provenance=false \
     --sbom=false \
     --build-arg IMAGE_TAG=v1 \
     -t lab009-lambda:dev \
     ../../../../src/LAB-009/ImageLabFunction
   ```
3. Uruchom `terraform apply -target=aws_ecr_repository.lambda`, aby utworzyć ECR.
4. Wypchnij obraz do ECR pod konkretnym tagiem (np. `v1`).
5. Ustaw `image_tag` (np. w `terraform.tfvars`) i uruchom ponownie `terraform apply`.

## Komendy

```bash
terraform init
terraform plan
terraform apply -target=aws_ecr_repository.lambda
terraform apply
terraform output
```

## TODO(lab-009)

- Dopasuj handler i strukturę projektu C# do własnego kodu.
- Dodaj tagowanie zgodne ze standardem konta (`lab_tags`).
- Rozważ politykę lifecycle dla obrazów ECR po zakończeniu laba.

## Cleanup

```bash
terraform destroy
```
