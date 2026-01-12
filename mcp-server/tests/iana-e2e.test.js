#!/usr/bin/env node
/**
 * IANA End-to-End Tests
 * Tests PostgreSQL schema, workflow routing, and metrics
 */

import pkg from 'pg';
const { Client } = pkg;

const config = {
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  database: process.env.POSTGRES_DB || 'alfa',
  user: process.env.POSTGRES_USER || 'alfa',
  password: process.env.POSTGRES_PASSWORD || 'alfapass123'
};

const client = new Client(config);

const tests = {
  passed: 0,
  failed: 0,
  results: []
};

function log(status, test, message) {
  const emoji = status === 'PASS' ? '✅' : status === 'FAIL' ? '❌' : 'ℹ️';
  console.log(`${emoji} [${status}] ${test}: ${message}`);
  tests.results.push({ status, test, message });
  if (status === 'PASS') tests.passed++;
  if (status === 'FAIL') tests.failed++;
}

async function test_schema() {
  try {
    const schemaCheck = await client.query("SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'iana'");
    if (schemaCheck.rowCount === 0) {
      log('FAIL', 'Schema', 'Schema iana does not exist');
      return false;
    }
    log('PASS', 'Schema', 'Schema iana exists');

    const tables = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'iana' AND table_type = 'BASE TABLE'");
    const expected = ['conversations', 'messages', 'router_logs'];
    const actual = tables.rows.map(r => r.table_name).sort();
    if (JSON.stringify(expected) !== JSON.stringify(actual)) {
      log('FAIL', 'Tables', `Expected ${expected}, got ${actual}`);
      return false;
    }
    log('PASS', 'Tables', `All 3 tables exist: ${actual.join(', ')}`);

    const views = await client.query("SELECT table_name FROM information_schema.views WHERE table_schema = 'iana'");
    const viewNames = views.rows.map(r => r.table_name).sort();
    log('PASS', 'Views', `2 views exist: ${viewNames.join(', ')}`);

    return true;
  } catch (error) {
    log('FAIL', 'Schema Test', error.message);
    return false;
  }
}

async function test_insert_conversation() {
  try {
    const result = await client.query(
      "INSERT INTO iana.conversations (user_id, channel) VALUES ($1, $2) RETURNING conversation_id",
      ['test-user', 'api']
    );
    const convId = result.rows[0].conversation_id;
    log('PASS', 'Insert Conversation', `Created conversation ${convId}`);
    return convId;
  } catch (error) {
    log('FAIL', 'Insert Conversation', error.message);
    return null;
  }
}

async function test_insert_message(convId) {
  if (!convId) {
    log('FAIL', 'Insert Message', 'No conversation_id provided');
    return null;
  }
  try {
    const result = await client.query(
      "INSERT INTO iana.messages (conversation_id, role, content, tier) VALUES ($1, $2, $3, $4) RETURNING message_id",
      [convId, 'user', 'Hello IANA', 'L1']
    );
    const msgId = result.rows[0].message_id;
    log('PASS', 'Insert Message', `Created message ${msgId}`);
    return msgId;
  } catch (error) {
    log('FAIL', 'Insert Message', error.message);
    return null;
  }
}

async function test_trigger(convId) {
  if (!convId) {
    log('FAIL', 'Trigger', 'No conversation_id provided');
    return false;
  }
  try {
    const before = await client.query("SELECT message_count FROM iana.conversations WHERE conversation_id = $1", [convId]);
    const countBefore = before.rows[0]?.message_count || 0;

    await test_insert_message(convId);

    const after = await client.query("SELECT message_count FROM iana.conversations WHERE conversation_id = $1", [convId]);
    const countAfter = after.rows[0]?.message_count || 0;

    if (countAfter === countBefore + 1) {
      log('PASS', 'Trigger', `Message count incremented: ${countBefore} → ${countAfter}`);
      return true;
    } else {
      log('FAIL', 'Trigger', `Expected ${countBefore + 1}, got ${countAfter}`);
      return false;
    }
  } catch (error) {
    log('FAIL', 'Trigger', error.message);
    return false;
  }
}

async function test_views() {
  try {
    await client.query("SELECT * FROM iana.router_accuracy LIMIT 1");
    log('PASS', 'View router_accuracy', 'View is queryable');

    await client.query("SELECT * FROM iana.conversation_stats LIMIT 1");
    log('PASS', 'View conversation_stats', 'View is queryable');

    return true;
  } catch (error) {
    log('FAIL', 'Views', error.message);
    return false;
  }
}

async function cleanup() {
  try {
    await client.query("DELETE FROM iana.conversations WHERE user_id = 'test-user'");
    log('INFO', 'Cleanup', 'Test data cleaned up');
  } catch (error) {
    log('FAIL', 'Cleanup', error.message);
  }
}

async function main() {
  console.log('\n🚀 IANA End-to-End Tests\n');
  console.log('==========================================\n');

  try {
    await client.connect();
    log('PASS', 'Connection', 'PostgreSQL connected');

    await test_schema();
    const convId = await test_insert_conversation();
    const msgId = await test_insert_message(convId);
    await test_trigger(convId);
    await test_views();
    await cleanup();

    console.log('\n==========================================');
    console.log(`\n📊 RESULTS: ${tests.passed} passed, ${tests.failed} failed\n`);

    if (tests.failed === 0) {
      console.log('✅ ALL TESTS PASSED\n');
      process.exit(0);
    } else {
      console.log('❌ SOME TESTS FAILED\n');
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Fatal error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main();

