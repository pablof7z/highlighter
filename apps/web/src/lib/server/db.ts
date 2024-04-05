import { drizzle, type BetterSQLite3Database } from 'drizzle-orm/better-sqlite3';
import { migrate } from 'drizzle-orm/better-sqlite3/migrator';

import Database from 'better-sqlite3';

const sqlite = new Database('highlighter.db');
const db: BetterSQLite3Database = drizzle(sqlite);

export default db;

try {
    migrate(db, { migrationsFolder: 'src/lib/server/migrations' });
} catch (error: any) {
    console.log(error);
}