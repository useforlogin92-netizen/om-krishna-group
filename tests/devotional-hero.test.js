const test = require("node:test");
const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");

const homepage = readFileSync(join(__dirname, "..", "index.html"), "utf8");
const stylesheet = readFileSync(
  join(__dirname, "..", "src", "shared", "styles", "global.css"),
  "utf8"
);

test("homepage contains the devotional hero preview and clearly labels pending media", () => {
  assert.match(homepage, /class="hero-art devotional-hero"/);
  assert.match(homepage, /ॐ नमः शिवाय/);
  assert.match(homepage, /Visual effects preview · real video\/audio pending/);
});

test("devotional visual effects are scoped to the hero artwork", () => {
  assert.match(stylesheet, /\.devotional-hero\s*\{/);
  assert.match(stylesheet, /\.devotional-particle\s*\{/);
  assert.match(stylesheet, /@keyframes devotional-rays/);
  assert.match(stylesheet, /@keyframes devotional-orbit/);
});

test("reduced-motion preference disables devotional animations", () => {
  assert.match(
    stylesheet,
    /@media\s*\(prefers-reduced-motion:\s*reduce\)\s*\{[^}]*\.devotional-hero:before[^}]*animation:\s*none/s
  );
});
