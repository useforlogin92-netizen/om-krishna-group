import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const read = (path) => readFileSync(new URL(path, import.meta.url), "utf8");

test("homepage links to chat without removing the existing profile links", () => {
  const html = read("../index.html");
  assert.match(html, /src\/pages\/chat\.html/);
  assert.match(html, /src\/pages\/om\.html/);
  assert.match(html, /src\/pages\/krishna\.html/);
});

test("chat page includes member and visitor experiences and required fields", () => {
  const html = read("../src/pages/chat.html");
  assert.match(html, /Family private chat/);
  assert.match(html, /Visitor live chat/);
  assert.match(html, /type="email"/);
  assert.match(html, /maxlength="1500"/);
  assert.match(html, /preview data is not sent or saved/i);
});

test("visitor form explicitly does not send or persist data", () => {
  const js = read("../src/shared/scripts/chat.js");
  assert.match(js, /nothing was sent or stored/);
  assert.match(js, /preventDefault\(\)/);
});

test("registration preview warns against entering credentials", () => {
  const html = read("../src/pages/register.html");
  assert.match(html, /not connected to Supabase Auth yet/);
  assert.match(html, /do not enter a real password/);
});

test("draft chat schema keeps all chat tables behind RLS and does not grant anon access", () => {
  const sql = read("../supabase/drafts/2026-10-31_chat_process.sql");
  for (const table of [
    "omkc_conversations",
    "omkc_conversation_participants",
    "omkc_messages",
    "omkc_message_reports",
    "omkc_visitor_requests",
  ]) {
    assert.match(sql, new RegExp(`alter table public\\.${table} enable row level security`));
  }
  assert.match(sql, /DO NOT APPLY TO PRODUCTION/);
  assert.match(sql, /Public\/anon users must never receive direct INSERT\/SELECT access/);
});
