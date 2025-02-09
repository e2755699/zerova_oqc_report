# Zerova OQC Report

## 项目配置步骤

1. 复制配置文件模板：
   ```bash
   cp config.template.json config.json
   ```

2. 在 `config.json` 中填入实际的配置值：
   - clientId: Azure AD 应用程序 ID
   - clientSecret: Azure AD 应用程序密钥
   - tenantId: Azure AD 租户 ID
   - siteId: SharePoint 站点 ID
   - driveId: SharePoint 驱动器 ID

3. 或者设置环境变量：
   ```bash
   export AZURE_CLIENT_ID="your_client_id"
   export AZURE_CLIENT_SECRET="your_client_secret"
   export AZURE_TENANT_ID="your_tenant_id"
   export AZURE_REDIRECT_URI="http://localhost:8000/callback"
   export SHAREPOINT_SITE_ID="your_site_id"
   export SHAREPOINT_DRIVE_ID="your_drive_id"
   ```

## 注意事项
- 不要将 `config.json` 提交到 Git 仓库
- 确保 `.gitignore` 中包含 `config.json`
- 每个开发者需要使用自己的配置文件
