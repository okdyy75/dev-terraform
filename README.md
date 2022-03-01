# dev-terraform
terraform検証用

## 実行環境設定
- aws profileで「dev-user」、「prd-user」を作成していること
- tfenvがインストールされていること
- tfstateファイルを共有管理するためのS3バケットが作成されていること

```bash
# 環境変数ファイル作成
cd dev
cp ../example.tfvars dev.tfvars
```

## 実行方法
```bash
# プロファイル設定(aws-cli v1)
export AWS_DEFAULT_PROFILE=dev-user

# state確認
terraform state show xxx.xxxx

# plan
terraform plan -var-file=dev.tfvars

# apply
terraform apply -var-file=dev.tfvars


```
