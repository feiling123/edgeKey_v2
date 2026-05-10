import { logger } from "../lib/logger";
import migration0001 from "../prisma/migrations/0001_init.sql?raw";
import migration0002 from "../prisma/migrations/0002_runtime_secret.sql?raw";
import seedSql from "../scripts/seed.sql?raw";

const bootstrapPromises = new WeakMap<D1Database, Promise<void>>();
const migrationTable = "__edgekey_runtime_migrations";

const migrations = [
  { id: "0001_init", sql: toIdempotentSql(migration0001) },
  { id: "0002_runtime_secret", sql: toIdempotentSql(migration0002) },
];

export function ensureD1Ready(database: D1Database) {
  const pending = bootstrapPromises.get(database);
  if (pending) return pending;

  const promise = bootstrapD1(database).catch((error) => {
    bootstrapPromises.delete(database);
    throw error;
  });
  bootstrapPromises.set(database, promise);
  return promise;
}

async function bootstrapD1(database: D1Database) {
  await database.exec(`
    CREATE TABLE IF NOT EXISTS "${migrationTable}" (
      "id" TEXT NOT NULL PRIMARY KEY,
      "appliedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `);

  const appliedRows = await database
    .prepare(`SELECT "id" FROM "${migrationTable}"`)
    .all<{ id: string }>();
  const applied = new Set((appliedRows.results ?? []).map((row) => row.id));

  for (const migration of migrations) {
    if (applied.has(migration.id)) continue;

    await database.exec(migration.sql);
    await database
      .prepare(`INSERT OR REPLACE INTO "${migrationTable}" ("id", "appliedAt") VALUES (?, CURRENT_TIMESTAMP)`)
      .bind(migration.id)
      .run();
  }

  await database.exec(seedSql);

  logger.info("d1.bootstrap.completed");
}

function toIdempotentSql(sql: string) {
  return sql
    .replace(/CREATE UNIQUE INDEX\s+"/g, 'CREATE UNIQUE INDEX IF NOT EXISTS "')
    .replace(/CREATE INDEX\s+"/g, 'CREATE INDEX IF NOT EXISTS "')
    .replace(/CREATE TABLE\s+"/g, 'CREATE TABLE IF NOT EXISTS "');
}
