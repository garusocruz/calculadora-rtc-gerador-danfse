# Deploy

Os triggers do Cloud Build moram em `lynko-terraform`, no módulo `adapters/gcp/delivery/calculadora_cicd`. Este repositório não aplica Terraform no Cloud Build (`_RUN_TERRAFORM=0`) e não publica no Artifact Registry.

A publicação da versão é no PyPI, no push da `main`, pelo `cloudbuild-prod.yaml`.
