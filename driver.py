import psycopg2
import aiosql

# db-related configuration
conn = psycopg2.connect("")
conn.autocommit = True
stmts = aiosql.from_path("driver.sql", "psycopg2")

for test_id, doc_id, corpus, body in stmts.get_all_tests(conn):
    print(doc_id)


