import crim
from dblib import conn, stmts

def store_pii(testrun_id, entity_code, entity_list, body):
    start_pos = 0
    for p in entity_list:
        start_idx = body.find(p, start_pos)
        end_idx = start_idx + len(p)
        start_pos = end_idx
        print(f'{entity_code}, {p}, {start_idx}, {end_idx}')
        stmts.add_result(conn, testrun_id=testrun_id, 
                         entity_code=entity_code, entity_text=p,
                         start_idx=start_idx, end_idx=end_idx)


run_id = stmts.add_run(conn, method_code='muckrock')
for test_id, doc_id, corpus, body in stmts.get_all_tests(conn): 
    print(test_id, doc_id, corpus)
    testrun_id = stmts.add_testrun(conn, run_id=run_id, test_id=test_id)
    store_pii(testrun_id, 'ssn', crim.ssn_numbers(body), body)
    store_pii(testrun_id, 'phone_number', crim.phones(body), body)
    store_pii(testrun_id, 'ban', crim.iban_numbers(body), body)
    # store_pii(testrun_id, 'credit_card', crim.credit_cards(body), body)
