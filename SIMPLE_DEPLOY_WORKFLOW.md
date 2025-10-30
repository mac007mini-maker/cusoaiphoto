# Simple Deploy Workflow - Main Branch Only

## Overview
Quy trình đơn giản: **main = production**, iterate nhanh, Railway auto-deploy.

---

## Daily Workflow

### 1. Develop & Test Local
```bash
# Make changes to code
# Test trên iOS simulator
./run_ios_simulator.sh

# Hoặc test backend local
python railway_app.py
```

### 2. Commit to Main
```bash
# Check changes
git status

# Add all changes
git add .

# Commit with meaningful message
git commit -m "feat: Add new feature X"
# hoặc
git commit -m "fix: Fix bug Y"
# hoặc
git commit -m "chore: Update dependencies"
```

### 3. Push to GitHub → Auto Deploy
```bash
# Push lên main
git push origin main

# Railway sẽ tự động:
# 1. Detect commit mới
# 2. Build backend (2-3 phút)
# 3. Deploy lên production
# 4. Health check tại /health
```

### 4. Verify Deployment
```bash
# Wait 2-3 phút, sau đó test
curl https://web-production-a7698.up.railway.app/health

# Kiểm tra thêm endpoint Nano Banana (cần prompt + KIE_API_KEY)
curl -X POST \
  https://web-production-a7698.up.railway.app/api/kie/nano-banana \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"test"}'
# ➜ Nếu chưa set KIE_API_KEY sẽ trả về lỗi 500 "not configured" (đã OK)
# ➜ Nếu key hợp lệ, backend trả JSON từ KIE Nano Banana API

# Kết quả mong đợi:
# {
#   "status": "healthy",
#   "checks": {...},
#   "timestamp": 1234567890.0,
#   "version": "1.0.0"
# }
```

---

## Common Scenarios

### Nếu Deploy Lỗi

#### Option 1: Fix Forward (Recommended)
```bash
# Fix bug local
# Test kỹ
# Commit & push fix ngay
git add .
git commit -m "fix: Critical bug in X"
git push origin main
```

#### Option 2: Rollback via Railway UI
1. Vào Railway Dashboard → Deployments
2. Click vào deployment trước đó (green checkmark)
3. Click "Redeploy"
4. Sau đó fix bug local và push lại

#### Option 3: Git Revert
```bash
# Revert commit lỗi (tạo commit mới)
git revert HEAD
git push origin main

# Railway sẽ deploy bản reverted
```

### Multiple Commits in Progress

```bash
# Nếu đang làm dở, muốn commit nhưng chưa push
git add .
git commit -m "wip: Work in progress on feature X"

# Làm tiếp, commit thêm
git commit -m "feat: Complete feature X"

# Khi sẵn sàng, push tất cả cùng lúc
git push origin main
```

### Check Deployment History

```bash
# Xem lịch sử commits
git log --oneline -10

# So sánh 2 commits
git diff <commit1> <commit2>

# Xem thay đổi của 1 commit
git show <commit-hash>
```

---

## Railway Monitoring

### Health Check
```bash
# Check backend status
curl https://web-production-a7698.up.railway.app/health | python3 -m json.tool
```

### View Logs
1. Vào Railway Dashboard
2. Click service "web"
3. Tab "Deployments" → Click deployment mới nhất
4. Xem logs realtime

### Environment Variables
1. Railway Dashboard → Settings → Variables
2. Thêm/sửa biến môi trường:
   - `REPLICATE_API_TOKEN`
   - `HUGGINGFACE_TOKEN`
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `PIAPI_API_KEY`
   - `KIE_API_KEY`

---

## Tips

### Pre-push Checklist
- [ ] Code đã test local
- [ ] Không có API keys hardcoded
- [ ] Commit message rõ ràng
- [ ] Nếu thay đổi lớn, backup code trước

### Commit Message Convention
```
feat: Thêm tính năng mới
fix: Sửa bug
chore: Update dependencies, config
docs: Update documentation
perf: Performance improvements
refactor: Refactor code
```

### Quick Commands
```bash
# Status
git status

# Diff uncommitted changes
git diff

# Undo local changes (chưa commit)
git restore <file>

# Undo last commit (chưa push)
git reset --soft HEAD~1

# View remote URL
git remote -v

# Pull latest from main (nếu làm việc nhiều máy)
git pull origin main
```

---

## Emergency Contacts

- **Railway Dashboard**: https://railway.app/dashboard
- **GitHub Repo**: https://github.com/mac007mini-maker/cusoaiphoto
- **API Domain**: https://web-production-a7698.up.railway.app

---

## Next Steps

Khi dự án lớn hơn, có thể consider:
1. Tạch staging branch cho test
2. Setup CI/CD với automated tests
3. Add Sentry/Crashlytics monitoring
4. Setup alerts cho Railway deployment failures

Nhưng hiện tại, simple workflow này đủ cho iterate nhanh và lên production!

