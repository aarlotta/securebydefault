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

## 🧠 Getting Started Best Practices

Before running the script, make sure PowerShell is allowed to execute local scripts:

### 🔧 Set Execution Policy
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

This allows local scripts to run securely while still protecting you from unsigned internet content.

---

### 📂 Recommended Setup Workflow

1. **Go to a non-system disk (like `D:\` or `E:\`)** for a clean workspace:

   ```powershell
   cd E:\
   ```

2. **Create your new project folder**:

   ```powershell
   mkdir MyProject
   cd MyProject
   ```

3. **Download the script** (manually or via browser/git):

   * From GitHub: [https://github.com/aarlotta/securebydefault](https://github.com/aarlotta/securebydefault)

4. **Run the bootstrap script**:

   ```powershell
   .\Initialize-SecureProject.ps1
   ```

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

## 🛑 Disclaimer

This project is provided **as-is, without warranty**.
Use it at your own risk. BAX IT SERVICES INC. and Anderson Arlotta assume no responsibility for any damages, data loss, or security issues resulting from its use.

📌 **Free support is not provided.**
This project is intended as a professional tool for experienced developers. If you require customization, support, or enhancements, please consider hiring the author.

---

## 🤝 Sponsor or Hire the Creator

If you value secure, production-quality engineering tools like this, consider supporting the developer behind it.

💼 **Hire for custom infrastructure, automation, or PowerShell projects**
💰 **Support ongoing open-source work**

👉 [**Become a Sponsor on GitHub**](https://github.com/sponsors/aarlotta?frequency=one-time&sponsor=aarlotta)

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