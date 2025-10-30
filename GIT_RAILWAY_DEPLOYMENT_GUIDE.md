# Git + Railway Deployment Guide - Safe Workflow với Rollback
**Mục tiêu:** Push code lên GitHub an toàn, Railway tự động deploy, dễ dàng rollback khi có lỗi.

---

## Table of Contents
1. [Khái niệm Git cơ bản](#khái-niệm-git-cơ-bản)
2. [Setup Git Repository](#setup-git-repository)
3. [Git Workflow - Branching Strategy](#git-workflow---branching-strategy)
4. [Push Code lên GitHub an toàn](#push-code-lên-github-an-toàn)
5. [Railway Auto-Deploy Setup](#railway-auto-deploy-setup)
6. [Rollback Procedures](#rollback-procedures)
7. [CI/CD Best Practices](#cicd-best-practices)

---

## Khái niệm Git Cơ bản

### Git là gì?
- **Git**: Hệ thống version control - lưu lại lịch sử thay đổi code.
- **Commit**: Một "snapshot" của code tại một thời điểm.
- **Branch**: Nhánh phát triển độc lập (ví dụ: `main`, `dev`, `feature/new-ai`).
- **Remote**: Server lưu code (ví dụ: GitHub).

### Tại sao cần Git?
1. **Lưu lịch sử**: Xem ai đổi gì, khi nào.
2. **Rollback dễ dàng**: Quay lại phiên bản cũ khi có lỗi.
3. **Cộng tác**: Nhiều người làm cùng lúc, không đụng độ.
4. **Backup**: Code luôn an toàn trên GitHub.

---

## Setup Git Repository

### Bước 1: Check Git đã được cài đặt chưa

```bash
git --version
# Nếu chưa có, cài đặt từ: https://git-scm.com/
```

### Bước 2: Configure Git (lần đầu tiên)

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

### Bước 3: Khởi tạo Git trong project (nếu chưa có)

```bash
cd /Users/henry/Downloads/bk/aihubtech35pro
git init
```

**⚠️ LƯU Ý:** Project này có thể đã có Git repo rồi. Check bằng:
```bash
git status
# Nếu thấy "On branch main" => đã có Git repo
```

### Bước 4: Tạo `.gitignore` (Quan trọng!)

File này chỉ định các file/folder **KHÔNG** push lên GitHub (ví dụ: secrets, build files).

**Kiểm tra file `.gitignore` đã tồn tại:**
```bash
cat .gitignore
```

**Đảm bảo có các dòng này:**
```
# Secrets (NEVER commit!)
secrets.env
*.env
.env
.env.local
*.key
*.p12
*.mobileprovision

# Build artifacts
build/
*.apk
*.ipa
*.dSYM.zip
*.dSYM

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/.last_build_id
ios/Flutter/flutter_export_environment.sh

# Android
android/.gradle/
android/local.properties
android/app/google-services.json  # If contains sensitive data

# Python
__pycache__/
*.pyc
.venv/
venv/
.env

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
```

---

## Git Workflow - Branching Strategy

### Recommended Branch Structure

```
main (production)
  ├── staging (pre-production testing)
  └── dev (development)
      ├── feature/nano-banana
      ├── feature/new-ui
      └── hotfix/crash-fix
```

### Branch Naming Convention

- `main`: Production code (chỉ merge code đã test kỹ)
- `staging`: Pre-production (test trước khi lên main)
- `dev`: Development (code đang phát triển)
- `feature/xxx`: Tính năng mới (ví dụ: `feature/nano-banana-api`)
- `hotfix/xxx`: Sửa lỗi khẩn cấp (ví dụ: `hotfix/crash-on-ios`)

### Tại sao cần nhiều branch?

✅ **Ưu điểm:**
1. `main` luôn stable → production luôn hoạt động
2. Test trên `staging` trước → catch lỗi sớm
3. Phát triển tính năng mới trên `feature/*` → không ảnh hưởng `main`
4. Rollback dễ dàng → chỉ cần revert merge commit

---

## Push Code lên GitHub An toàn

### Workflow Chuẩn: Feature Branch Flow

#### Bước 1: Tạo branch mới từ `dev`

```bash
# 1. Đảm bảo bạn đang ở branch dev và có code mới nhất
git checkout dev
git pull origin dev

# 2. Tạo branch mới cho tính năng
git checkout -b feature/nano-banana-integration

# 3. Làm việc, sửa code, test...
```

#### Bước 2: Commit changes

```bash
# 1. Xem file nào đã thay đổi
git status

# 2. Stage các file muốn commit (không nên `git add .` nếu có file rác)
git add lib/services/kie_service.dart
git add api/index.py
git add services/kie_gateway.py

# 3. Commit với message rõ ràng
git commit -m "feat: Add Kie Nano Banana API integration

- Add kie_service.dart client
- Add backend route /api/kie/generate
- Add kie_gateway.py with error handling
- Update UI to show Nano Banana templates"

# Commit message format:
# feat: New feature
# fix: Bug fix
# docs: Documentation
# refactor: Code refactoring
# test: Add tests
# chore: Maintenance (update dependencies, etc.)
```

#### Bước 3: Push branch lên GitHub

```bash
# Push lần đầu tiên
git push -u origin feature/nano-banana-integration

# Các lần sau (nếu có thêm commits)
git push
```

#### Bước 4: Tạo Pull Request (PR) trên GitHub

1. Vào GitHub repo: `https://github.com/your-username/your-repo`
2. Thấy thông báo "Compare & pull request" → Click
3. **Base branch:** `dev` ← **Compare branch:** `feature/nano-banana-integration`
4. Viết mô tả PR:
```markdown
## Changes
- Integrated Kie Nano Banana API for image prompt processing
- Added new UI category "Nano Banana"
- Backend proxy route for API calls

## Testing
- [x] Tested on iOS Simulator
- [x] Tested on Android Emulator
- [ ] Tested on real device (TODO)

## Screenshots
(Attach screenshots if UI changes)
```
5. Click **"Create Pull Request"**

#### Bước 5: Review & Merge

**Nếu làm một mình:**
- Review code trên GitHub (đọc lại diff)
- Nếu OK → Click **"Merge Pull Request"** → **"Confirm Merge"**

**Nếu làm team:**
- Request review từ teammate
- Chờ approve
- Sau đó merge

#### Bước 6: Cleanup

```bash
# 1. Về lại branch dev
git checkout dev

# 2. Pull code mới nhất (đã bao gồm feature vừa merge)
git pull origin dev

# 3. Xóa feature branch local (optional, giữ cho gọn)
git branch -d feature/nano-banana-integration

# 4. Xóa feature branch trên GitHub (optional)
git push origin --delete feature/nano-banana-integration
```

---

### Workflow Nhanh: Direct Push (CHỈ cho dev branch)

**⚠️ Chỉ dùng cho `dev` branch. KHÔNG BAO GIỜ push trực tiếp lên `main`!**

```bash
# 1. Đảm bảo đang ở dev branch
git checkout dev

# 2. Pull code mới nhất
git pull origin dev

# 3. Làm việc, sửa code...

# 4. Add & Commit
git add .
git commit -m "fix: Minor bug fix in face swap"

# 5. Push
git push origin dev
```

---

## Railway Auto-Deploy Setup

### Bước 1: Connect GitHub Repository to Railway

1. Login Railway: https://railway.app/
2. Vào project: "Viso AI Backend"
3. Click **"Settings"** → **"Service"** → **"Source"**
4. Click **"Connect GitHub Repo"**
5. Chọn repo: `your-username/aihubtech35pro`
6. Chọn branch để auto-deploy: **`main`**

### Bước 2: Configure Environment Variables trên Railway

**Quan trọng:** Các biến môi trường backend (API keys) KHÔNG push lên GitHub → phải set trên Railway.

1. Railway Dashboard → Project → **"Variables"** tab
2. Add các biến sau:

```env
# AI Services
HUGGINGFACE_TOKEN=hf_xxxxxxxxxxxx
REPLICATE_API_TOKEN=r8_xxxxxxxxxxxx
PIAPI_API_KEY=your_piapi_key
KIE_API_KEY=kie_xxxxxxxxxxxx  # NEW: Nano Banana diffusion model
KIE_API_BASE=https://kie.ai/nano-banana  # Optional override (default already set)

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Backend Security
API_KEY=your-secure-random-key  # Generate: openssl rand -hex 32

# Python
PYTHONUNBUFFERED=1
```

3. Click **"Save"** → Railway sẽ tự động restart service với biến mới.

> ✅ **Test nhanh:** Sau khi thêm `KIE_API_KEY`, chạy `curl -X POST https://<railway-domain>/api/kie/nano-banana -d '{"prompt":"test"}' -H 'Content-Type: application/json'`. Bạn sẽ nhận về JSON kết quả (hoặc thông báo lỗi rõ ràng nếu KEY sai).

### Bước 3: Configure Build & Start Commands

**Railway thường tự detect, nhưng để chắc chắn:**

1. Railway Dashboard → **"Settings"** → **"Build & Deploy"**
2. **Build Command:** (leave empty, Railway auto-detects from requirements.txt)
3. **Start Command:**
```bash
gunicorn -w 4 -k uvicorn.workers.UvicornWorker api.index:app
```

Or use `railway.toml` (đã có trong project):
```toml
[build]
builder = "nixpacks"

[deploy]
startCommand = "gunicorn -w 4 -k uvicorn.workers.UvicornWorker api.index:app"
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 10
```

### Bước 4: Add Health Check Endpoint

**Railway cần endpoint `/health` để check service còn sống không.**

Thêm vào `api/index.py` (nếu chưa có):
```python
@app.route('/health', methods=['GET'])
@app.route('/healthz', methods=['GET'])
def health_check():
    """Health check endpoint for Railway"""
    return jsonify({
        'status': 'healthy',
        'timestamp': time.time(),
        'service': 'Viso AI Backend',
        'version': '1.0.0'
    }), 200
```

### Bước 5: Test Auto-Deploy

```bash
# 1. Make a small change
echo "# Test deploy" >> README.md

# 2. Commit & push to main
git add README.md
git commit -m "test: Trigger Railway deploy"
git push origin main

# 3. Watch Railway dashboard
# Railway sẽ:
#   - Detect new commit
#   - Pull code
#   - Build (install dependencies)
#   - Deploy (start service)
#   - Health check (/health endpoint)
#   - Switch traffic to new version
```

**Deployment logs:**
- Vào Railway Dashboard → **"Deployments"** tab
- Click vào deployment mới nhất → xem logs real-time

---

## Rollback Procedures

### Tình huống: Code mới push lên có bug, cần rollback ngay

#### Method 1: Rollback trên Railway (Nhanh nhất)

**Railway lưu lại tất cả deployments cũ → chỉ cần switch back.**

1. Railway Dashboard → **"Deployments"** tab
2. Tìm deployment cũ (stable, không có bug)
3. Click **"⋮" (three dots)** → **"Redeploy"**
4. Railway sẽ deploy lại version cũ → tức thì

**Ưu điểm:**
- Nhanh (1-2 phút)
- Không cần động git
- Tạm thời, có thể fix bug xong deploy lại

**Nhược điểm:**
- Không sửa được code trên GitHub (vẫn còn bug code)
- Lần push tiếp theo sẽ deploy lại code bug

---

#### Method 2: Git Revert (Khuyến nghị)

**Tạo commit mới "undo" commit cũ → an toàn, giữ lịch sử.**

```bash
# 1. Identify commit gây lỗi
git log --oneline
# Output:
# abc1234 (HEAD -> main) feat: Add Nano Banana API  ← Commit này có bug
# def5678 fix: Fix face swap timeout
# ghi9012 feat: Add health check

# 2. Revert commit bug
git revert abc1234

# Git sẽ tạo commit mới "Revert 'feat: Add Nano Banana API'"

# 3. Push
git push origin main

# 4. Railway tự động deploy version "reverted" (không còn bug)
```

**Ưu điểm:**
- An toàn, không mất lịch sử
- Team biết đã rollback
- Sau này có thể revert lại revert (re-apply feature)

**Nhược điểm:**
- Tốn thời gian build/deploy (5-10 phút)

---

#### Method 3: Git Reset (Nguy hiểm, chỉ dùng khi thật sự cần)

**Xóa commit khỏi lịch sử → như chưa từng tồn tại.**

**⚠️ CẢNH BÁO:** Chỉ dùng nếu:
- Commit chưa được ai pull về
- Hoặc làm một mình
- Hoặc thật sự muốn xóa lịch sử (ví dụ: push nhầm secrets)

```bash
# 1. Identify commit muốn quay lại
git log --oneline
# def5678 fix: Fix face swap timeout  ← Quay về đây

# 2. Reset về commit này (XÓA tất cả commits sau đó)
git reset --hard def5678

# 3. Force push (NGUY HIỂM!)
git push origin main --force

# Railway sẽ deploy lại version def5678
```

**Ưu điểm:**
- "Xóa sạch" lịch sử commit bug

**Nhược điểm:**
- MẤT LỊCH SỬ (không lấy lại được)
- Conflict với người khác nếu họ đã pull
- Không khuyến nghị cho production

---

#### Method 4: Cherry-pick (Selective Rollback)

**Chỉ áp dụng một số commit cụ thể từ history.**

```bash
# Tình huống: Có 3 commits mới, chỉ muốn giữ 2, bỏ 1

# 1. Tạo branch backup
git branch backup-before-rollback

# 2. Reset về commit trước 3 commits
git reset --hard HEAD~3

# 3. Cherry-pick 2 commits muốn giữ
git cherry-pick abc1234  # Commit 1 (good)
git cherry-pick def5678  # Commit 2 (good)
# Bỏ commit 3 (bad)

# 4. Force push
git push origin main --force
```

---

### Best Practices for Rollback

1. **Luôn test kỹ trên `dev`/`staging` trước khi merge vào `main`**
2. **Tag stable releases:**
```bash
git tag -a v1.0.0 -m "Release 1.0.0 - Stable"
git push origin v1.0.0
```
   → Dễ dàng quay lại: `git checkout v1.0.0`

3. **Sử dụng Railway Deployments history** cho rollback nhanh
4. **Prefer `git revert`** hơn `git reset --force` (trừ khi thật cần)
5. **Monitor Railway logs** sau mỗi deploy để catch lỗi sớm

---

## CI/CD Best Practices

### Recommended Workflow

```
Developer
  ↓
Push to feature branch
  ↓
Create Pull Request to dev
  ↓
[CI] Run tests, linting (GitHub Actions)  ← Tự động
  ↓
Review & Merge to dev
  ↓
[CD] Auto-deploy to Railway (dev environment)  ← Tự động
  ↓
Test on dev
  ↓
Merge dev → staging
  ↓
[CD] Auto-deploy to Railway (staging environment)
  ↓
QA Test on staging
  ↓
Merge staging → main
  ↓
[CD] Auto-deploy to Railway (production)
  ↓
Monitor production logs, metrics
```

### Setup GitHub Actions (Optional, nên có)

Tạo file `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  pull_request:
    branches: [dev, staging, main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.x'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
    
  backend-test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest
    
    - name: Run backend tests
      run: pytest tests/
```

**Lợi ích:**
- Tự động chạy tests mỗi khi tạo PR
- Catch lỗi trước khi merge
- Không cần chạy thủ công

---

## Quick Reference: Git Commands Cheat Sheet

### Daily Commands

```bash
# Check status (file nào thay đổi)
git status

# View changes
git diff

# Stage files
git add <file>
git add .  # Add all (cẩn thận!)

# Commit
git commit -m "message"

# Push
git push origin <branch-name>

# Pull latest
git pull origin <branch-name>

# Switch branch
git checkout <branch-name>

# Create new branch
git checkout -b <new-branch-name>

# View commit history
git log --oneline --graph --all

# Undo last commit (giữ changes)
git reset --soft HEAD~1

# Discard local changes (NGUY HIỂM!)
git checkout -- <file>
git reset --hard  # Discard ALL changes
```

### Rollback Commands

```bash
# Revert commit (safe)
git revert <commit-hash>

# Reset to commit (NGUY HIỂM!)
git reset --hard <commit-hash>

# View what changed in commit
git show <commit-hash>

# Compare two commits
git diff <commit1> <commit2>
```

### Branch Management

```bash
# List all branches
git branch -a

# Delete local branch
git branch -d <branch-name>

# Delete remote branch
git push origin --delete <branch-name>

# Rename current branch
git branch -m <new-name>
```

---

## Checklist: Trước khi Push lên GitHub

✅ **Code Quality:**
- [ ] Code chạy không lỗi trên local
- [ ] Đã test trên iOS/Android (nếu thay đổi UI/logic)
- [ ] Đã chạy `flutter analyze` (không có warnings nghiêm trọng)
- [ ] Xóa `print()` debug statements hoặc console.log()

✅ **Security:**
- [ ] KHÔNG có secrets trong code (API keys, passwords)
- [ ] Kiểm tra `secrets.env` KHÔNG được commit
- [ ] `.gitignore` cấu hình đúng

✅ **Git Best Practices:**
- [ ] Commit message rõ ràng (feat/fix/docs/refactor/test/chore)
- [ ] Commit nhỏ, focused (không gộp 10 features vào 1 commit)
- [ ] Push lên feature branch, KHÔNG push trực tiếp lên `main`

✅ **Backend:**
- [ ] Environment variables được set trên Railway
- [ ] Health check endpoint `/health` hoạt động
- [ ] Logs không có errors khi test local

✅ **Testing:**
- [ ] Đã test trên `dev` environment trước
- [ ] Nếu thay đổi backend, test API endpoints bằng Postman/curl
- [ ] Nếu thay đổi UI, test trên nhiều screen sizes

---

## Kết luận

### Key Takeaways

1. **Luôn làm việc trên feature branch** → merge vào `dev` qua PR
2. **KHÔNG BAO GIỜ push trực tiếp lên `main`** → dùng PR workflow
3. **Railway tự động deploy khi push lên `main`** → kiểm soát bằng PR
4. **Rollback dễ dàng** → Railway Deployments hoặc `git revert`
5. **Secrets KHÔNG push lên GitHub** → set trên Railway Variables

### Next Steps

1. ✅ Setup Git repository (nếu chưa có)
2. ✅ Tạo `.gitignore` đúng cách
3. ✅ Connect GitHub repo với Railway
4. ✅ Configure environment variables trên Railway
5. ✅ Test deploy workflow bằng dummy commit
6. ✅ Thực hiện feature development theo workflow trên

---

**Hướng dẫn tiếp theo:** `PRODUCTION_READINESS_CHECKLIST.md`

