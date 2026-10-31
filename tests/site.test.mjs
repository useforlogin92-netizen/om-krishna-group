import test from "node:test";
import assert from "node:assert/strict";
import { readdir, readFile, access } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const htmlFiles = [];

async function walk(dir) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    if (entry.name === ".git" || entry.name === "node_modules") continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) await walk(full);
    else if (entry.isFile() && entry.name.endsWith(".html")) htmlFiles.push(full);
  }
}

await walk(root);

function rel(file) {
  return path.relative(root, file).replaceAll(path.sep, "/");
}

test("expected website pages exist", async () => {
  const expected = [
    "index.html",
    "src/pages/om.html",
    "src/pages/acting.html",
    "src/pages/cricket.html",
    "src/pages/activities.html",
    "src/pages/krishna.html",
    "src/pages/contact.html",
    "src/pages/admin.html"
  ];
  for (const file of expected) await access(path.join(root, file));
  assert.ok(htmlFiles.length >= expected.length, "HTML page discovery should include all expected pages");
});

test("every HTML page has a title, viewport and language", async () => {
  for (const file of htmlFiles) {
    const html = await readFile(file, "utf8");
    assert.match(html, /<html\b[^>]*\blang=["'][^"']+["']/i, rel(file) + " needs an html language");
    assert.match(html, /<title>\s*[^<]+\s*<\/title>/i, rel(file) + " needs a title");
    assert.match(html, /<meta\s+name=["']viewport["']/i, rel(file) + " needs a viewport meta tag");
  }
});

test("local href and src assets resolve to existing files", async () => {
  const missing = [];
  for (const file of htmlFiles) {
    const html = await readFile(file, "utf8");
    for (const match of html.matchAll(/\b(?:href|src)=["']([^"']+)["']/gi)) {
      const value = match[1].trim();
      if (!value || value.startsWith("#") || /^(?:https?:|mailto:|tel:|data:|javascript:)/i.test(value)) continue;
      const pathname = value.split(/[?#]/, 1)[0];
      if (!pathname) continue;
      const target = path.resolve(path.dirname(file), decodeURIComponent(pathname));
      if (!target.startsWith(root + path.sep) && target !== root) {
        missing.push(`${rel(file)} -> path escapes project: ${value}`);
        continue;
      }
      try { await access(target); }
      catch { missing.push(`${rel(file)} -> missing ${value}`); }
    }
  }
  assert.deepEqual(missing, [], missing.join("\n"));
});

test("inline JavaScript parses without syntax errors", async () => {
  for (const file of htmlFiles) {
    const html = await readFile(file, "utf8");
    for (const match of html.matchAll(/<script\b(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/gi)) {
      const code = match[1].trim();
      if (!code) continue;
      const checked = spawnSync(process.execPath, ["--check", "-"], {
        input: code,
        encoding: "utf8"
      });
      assert.equal(checked.status, 0, `${rel(file)} inline script syntax failed:\n${checked.stderr}`);
    }
  }
});

test("activity page keeps its non-production safety notices", async () => {
  const html = await readFile(path.join(root, "src/pages/activities.html"), "utf8");
  assert.match(html, /not uploaded or published/i);
  assert.match(html, /guardian approval/i);
  assert.match(html, /52428800/);
  assert.match(html, /allowedTypes/);
});

test("no obvious Supabase service-role secret is committed in website source", async () => {
  const suspicious = [];
  for (const file of htmlFiles) {
    const html = await readFile(file, "utf8");
    if (/service_role|sb_secret_[A-Za-z0-9_-]{12,}/i.test(html)) suspicious.push(rel(file));
  }
  assert.deepEqual(suspicious, [], "Never put Supabase service-role/secret keys in frontend HTML");
});
