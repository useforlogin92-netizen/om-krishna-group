import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const homepage = await readFile(new URL("../index.html", import.meta.url), "utf8");
const stylesheet = await readFile(new URL("../src/shared/styles/global.css", import.meta.url), "utf8");

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
