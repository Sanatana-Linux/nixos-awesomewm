import { tool } from "@opencode-ai/plugin"
import { execSync } from "child_process"
import * as fs from "fs"
import * as path from "path"

interface ConfigFile {
  path: string
  status: "ok" | "missing" | "error"
  error?: string
}

function checkConfigFile(filePath: string, relativePath: string): ConfigFile {
  try {
    if (!fs.existsSync(filePath)) {
      return { path: relativePath, status: "missing" }
    }
    return { path: relativePath, status: "ok" }
  } catch (e) {
    return { path: relativePath, status: "error", error: String(e) }
  }
}

export default tool({
  description: "Validate AwesomeWM config syntax and check required files exist. Runs 'awesome -c rc.lua --check' and validates that all project modules are loadable.",
  parameters: {
    type: "object",
    properties: {
      rootDir: {
        type: "string",
        description: "Project root directory. Defaults to current working directory.",
      },
      configPath: {
        type: "string",
        description: "Path to rc.lua. Defaults to rc.lua in rootDir.",
      },
      fix: {
        type: "boolean",
        description: "If true, also run 'stylua .' to auto-format before checking.",
        default: false,
      },
    },
  },
  execute: async (params: { rootDir?: string; configPath?: string; fix?: boolean }) => {
    const rootDir = params.rootDir || process.cwd()
    const configFile = params.configPath || "rc.lua"
    const fullConfigPath = path.resolve(rootDir, configFile)
    const shouldFix = params.fix || false

    const results: string[] = []
    const errors: string[] = []
    const warnings: string[] = []

    // 1. Check required files
    const requiredFiles = [
      "rc.lua",
      "configuration/init.lua",
      "ui/init.lua",
      "modules/init.lua",
      "lib/init.lua",
      ".stylua.toml",
    ]

    results.push("## Required Files\n")
    for (const rf of requiredFiles) {
      const check = checkConfigFile(path.join(rootDir, rf), rf)
      results.push(`| ${check.path} | ${check.status} |`)
      if (check.status !== "ok") {
        errors.push(`Missing required file: ${rf}`)
      }
    }

    // 2. Run stylua if --fix
    if (shouldFix) {
      results.push("\n## Formatting\n")
      try {
        execSync("stylua .", { cwd: rootDir, stdio: "pipe" })
        results.push("✓ stylua . — OK\n")
      } catch (e) {
        warnings.push(`stylua failed: ${String(e)}`)
        results.push("⚠ stylua . — had issues\n")
      }
    }

    // 3. Run awesome syntax check
    results.push("\n## Syntax Check\n")
    try {
      const output = execSync(`awesome -c "${fullConfigPath}" --check 2>&1`, {
        cwd: rootDir,
        encoding: "utf-8",
        stdio: "pipe",
      })
      results.push("✓ awesome -c rc.lua --check — PASSED\n")
    } catch (e: any) {
      const stderr = e.stderr || e.stdout || String(e)
      errors.push(`awesome syntax check FAILED`)
      results.push("✗ awesome -c rc.lua --check — FAILED\n")
      results.push("```\n" + stderr.trim() + "\n```\n")

      // Parse common errors
      if (stderr.includes("attempt to call a nil value")) {
        warnings.push("Module loading issue: a require() returned nil — check package.path")
      }
      if (stderr.includes("unexpected symbol")) {
        warnings.push("Lua syntax error near the reported line")
      }
      if (stderr.includes("module")) {
        warnings.push("Module not found — check package.path includes upstream/")
      }
    }

    // 4. Check key service files exist
    const serviceModules = ["audio", "battery", "network", "bluetooth", "brightness", "screenshot", "caps", "system_info", "garbage_collection"]
    results.push("\n## Service Modules\n")
    for (const svc of serviceModules) {
      const svcPath = path.join(rootDir, "service", svc, "init.lua")
      if (fs.existsSync(svcPath)) {
        results.push(`| service/${svc}/init.lua | present |`)
      } else {
        warnings.push(`Service module service/${svc}/init.lua not found`)
        results.push(`| service/${svc}/init.lua | missing |`)
      }
    }

    // 5. Summary
    const summary = {
      status: errors.length === 0 ? "pass" : "fail",
      fileCount: requiredFiles.length,
      errors: errors.length,
      warnings: warnings.length,
      fixApplied: shouldFix,
    }

    return {
      summary,
      report: results.join("\n"),
      errors,
      warnings,
    }
  },
})
