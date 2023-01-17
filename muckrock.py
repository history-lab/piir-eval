import crim
from dblib import conn, stmts

def store_pii(testrun_id, entity_code, entity_list):
    for p in entity_list:
        print(f'{entity_code}, {p}')
        stmts.add_result_noidx(conn, testrun_id=testrun_id, 
                               entity_code=entity_code, entity_text=p)


run_id = stmts.add_run(conn, method_code='muckrock')
for test_id, doc_id, corpus, body in stmts.get_all_tests(conn): 
    print(test_id, doc_id, corpus)
    testrun_id = stmts.add_testrun(conn, run_id=run_id, test_id=test_id)
    store_pii(testrun_id, 'ssn', crim.ssn_numbers(body))
    store_pii(testrun_id, 'ban', crim.iban_numbers(body))
    store_pii(testrun_id, 'credit_card', crim.credit_cards(body))
