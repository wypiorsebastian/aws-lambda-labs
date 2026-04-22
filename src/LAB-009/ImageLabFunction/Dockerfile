# Multi-stage build dla Lambda .NET 8 jako container image.
# Wzorzec zgodny z dokumentacją AWS (bazowy obraz + /var/task + CMD jako handler):
# https://docs.aws.amazon.com/lambda/latest/dg/csharp-image.html
# https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/lambda-creating-project-docker-image.html

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ImageLabFunction.csproj .
RUN dotnet restore ImageLabFunction.csproj

COPY . .
RUN dotnet publish ImageLabFunction.csproj \
  -c Release \
  -r linux-x64 \
  --self-contained false \
  -o /app/publish

FROM public.ecr.aws/lambda/dotnet:8

WORKDIR /var/task

ARG IMAGE_TAG=dev
ENV IMAGE_TAG=${IMAGE_TAG}

COPY --from=build /app/publish .

# Assembly name == nazwa projektu (.dll): ImageLabFunction
CMD ["ImageLabFunction::ImageLabFunction.Function::FunctionHandler"]
