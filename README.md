# 🔐 SecureByDefault

> **The Ultimate PowerShell Project Bootstrap**  
> Hardened. Idempotent. Git-Safe. Developer-First.

---

## 🚀 What Is This?

**SecureByDefault** is a production-grade PowerShell bootstrap system that builds secure, testable, and scalable module projects — in one command.

No more broken Git remotes. No more unsafe scripts. No more scattered folder chaos. This is the bootstrap **you'll use on every serious PowerShell project**.

Whether you're writing internal tools, building CI/CD pipelines, or publishing reusable PowerShell modules — this system gets you started safely, instantly, and beautifully.

---

## ✨ Why Use SecureByDefault?

| Feature | Benefit |
|--------|---------|
| 🛡️ Secure-by-Default | Git history is preserved. No remote damage, even on `-Force`. |
| 🔁 Idempotent Design | Rerun it safely — it only adds what's missing. |
| 🧪 Built-In Tests | Includes Pester tests to verify structure and integrity. |
| 🧱 Structured Layout | Professional layout for serious module development. |
| 📝 Commit Message Template | Sets a clean, semantic commit format globally. |

---

## 🧪 Try It In Seconds

```powershell
# First-time setup
.\Initialize-SecureProject.ps1

# Safe re-run (won't touch Git or remotes)
.\Initialize-SecureProject.ps1 -Force

# Run included tests
Invoke-Pester -Verbose
```

---

## 📦 What You Get

```
securebydefault/
├── modules/
│   └── SecureBootstrap/
├── tests/
├── Initialize-SecureProject.ps1
├── Run-Tests.ps1
├── .commit-template.txt
├── .gitignore
```

* Zero external dependencies
* Compatible with Windows + PowerShell 7+
* 100% offline and private

---

## 🏁 Built For

* Infrastructure engineers standardizing PowerShell projects
* DevSecOps professionals bootstrapping modules with testing
* Consultants and creators building reliable delivery pipelines

---

## 📝 Commit Template Format

```text
# <type>(<scope>): <short summary>
#
# Types: chore, feat, fix, docs, test, refactor, ci, perf
# Example: feat(module): add execution policy enforcement
```

---

## 🔖 Versioning

Use Git tags to lock stable versions:

```powershell
git tag -a v1.0.0 -m "Initial secure bootstrap release"
git push origin v1.0.0
```

---

## 🎯 Created By Anderson Arlotta

> 10+ years in systems engineering, cybersecurity, and DevOps.
> Founder of BAX IT SERVICES INC.
> I build systems that are **secure by default** and ready for production.

📫 Contact: [anderson@baxitservices.com](mailto:anderson@baxitservices.com)
🌐 GitHub: [https://github.com/aarlotta](https://github.com/aarlotta)

---

## 📄 License

Licensed under the [Apache License 2.0](LICENSE).

You are free to use, modify, and distribute this software with proper attribution. Commercial usage is permitted under the terms of the license. 