# GitHub Actions Secrets Setup

This guide shows how to configure GitHub Actions secrets for Docker Hub integration.

## Required Secrets for Docker Hub

To enable Docker Hub publishing in the release workflow, you need to configure two secrets:

### 1. DOCKERHUB_USERNAME

Your Docker Hub username.

**Setup Steps:**

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Set **Name** to: `DOCKERHUB_USERNAME`
5. Set **Secret** to: your Docker Hub username (e.g., `johndoe`)
6. Click **Add secret**

### 2. DOCKERHUB_TOKEN

A Docker Hub access token (recommended) or your Docker Hub password.

**Setup Steps:**

#### Creating a Docker Hub Access Token (Recommended)

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Go to **Account Settings** → **Security** → **Access Tokens**
3. Click **New Access Token**
4. Enter a description (e.g., "GitHub Actions for pterodactyl-image")
5. Set permissions to **Read, Write, Delete** (or Read & Write)
6. Click **Generate**
7. **Copy the token immediately** (you won't be able to see it again!)

#### Adding the Token to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Set **Name** to: `DOCKERHUB_TOKEN`
5. Set **Secret** to: the access token you just copied
6. Click **Add secret**

## Verification

After setting up the secrets, you can verify they're configured correctly:

### Via GitHub UI

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. You should see both secrets listed:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`

### Via Workflow Test

1. Trigger a release workflow manually:
   ```bash
   gh workflow run release.yml -f version=v0.0.1 -f push_to_dockerhub=true
   ```

2. Check the workflow logs:
   - Look for "Log in to Docker Hub" step
   - It should show "Login Succeeded" without errors

## Docker Hub Repository Setup

Before publishing, ensure you have created the repositories on Docker Hub:

### Option 1: Manual Creation

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Click **Create Repository**
3. Enter repository name: `panel`
4. Set visibility (Public or Private)
5. Click **Create**
6. Repeat for `wings` repository

### Option 2: Automatic Creation

Docker Hub can automatically create repositories on first push if you have the appropriate permissions. However, manual creation is recommended for better control over repository settings.

## Repository Naming Convention

The workflows use this naming convention:

```
<dockerhub-username>/panel
<dockerhub-username>/wings
```

For example, if your Docker Hub username is `johndoe`:
- Panel image: `johndoe/panel`
- Wings image: `johndoe/wings`

## Security Best Practices

### Access Token Management

1. **Use Access Tokens**: Never use your Docker Hub password as a secret
2. **Limit Permissions**: Only grant necessary permissions (Read & Write)
3. **Regular Rotation**: Rotate tokens every 90-180 days
4. **Unique Tokens**: Use different tokens for different projects
5. **Token Description**: Always use descriptive names for tokens

### Secret Management

1. **Never Commit Secrets**: Don't put secrets in code or configuration files
2. **Restrict Access**: Only repository admins should access secrets
3. **Audit Regularly**: Review who has access to repository secrets
4. **Use Organization Secrets**: For multiple repositories, consider organization-level secrets

### Token Revocation

If a token is compromised:

1. Immediately revoke it on Docker Hub:
   - Go to **Account Settings** → **Security** → **Access Tokens**
   - Find the token and click **Delete**

2. Update the GitHub secret with a new token

3. Re-run any failed workflows with the new token

## Troubleshooting

### Error: "Login Succeeded" but push fails

**Cause**: Repository doesn't exist on Docker Hub

**Solution**: Create the repositories manually on Docker Hub first

### Error: "unauthorized: authentication required"

**Cause**: Invalid credentials or token

**Solution**:
1. Verify the token is still valid on Docker Hub
2. Re-create the token if needed
3. Update the `DOCKERHUB_TOKEN` secret with the new value

### Error: "denied: requested access to the resource is denied"

**Cause**: Token lacks write permissions

**Solution**:
1. Create a new token with **Read, Write, Delete** permissions
2. Update the `DOCKERHUB_TOKEN` secret

### Workflow skips Docker Hub step

**Expected Behavior**: If secrets aren't configured, the workflow automatically skips Docker Hub publishing and only pushes to GHCR.

**To Enable**: Configure both `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets

## Testing Your Setup

### Test Without Publishing

Run the build workflow to verify images build correctly:

```bash
gh workflow run build.yml
```

### Test with GHCR Only

Create a test release without Docker Hub:

```bash
gh workflow run release.yml -f version=v0.0.1 -f push_to_dockerhub=false
```

### Test with Docker Hub

Create a test release with Docker Hub:

```bash
gh workflow run release.yml -f version=v0.0.1 -f push_to_dockerhub=true
```

### Verify Published Images

After successful release:

```bash
# Test GHCR image
docker pull ghcr.io/<username>/<repo>/panel:0.0.1

# Test Docker Hub image (if published)
docker pull <username>/panel:0.0.1
```

## Additional Resources

- [Docker Hub Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Login Action](https://github.com/docker/login-action)
- [Docker Build Push Action](https://github.com/docker/build-push-action)

## Support

If you encounter issues:

1. Check workflow logs for detailed error messages
2. Verify all secrets are correctly configured
3. Ensure Docker Hub repositories exist
4. Review this guide for common solutions
5. Open an issue on GitHub if problems persist
