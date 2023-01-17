import psycopg2
import aiosql

# db-related configuration
conn = psycopg2.connect("")
conn.autocommit = True
stmts = aiosql.from_path("driver.sql", "psycopg2")