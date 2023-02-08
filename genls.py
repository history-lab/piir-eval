from dblib import conn, stmts

GENLS_DIR="tests/cfpf/"

for test_id, doc_id, corpus, body in stmts.get_all_tests(conn):
    with open(GENLS_DIR + doc_id + '.txt', 'w') as file:
        file.write(body)