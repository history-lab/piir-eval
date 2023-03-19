import crim
from dblib import conn, stmts

def store_pii(taskrun_id, entity_code, entity_list, body):
    start_pos = 0
    for p in entity_list:
        start_idx = body.find(p, start_pos)
        end_idx = start_idx + len(p)
        start_pos = end_idx
        print(f'{entity_code}, {p}, {start_idx}, {end_idx}')
        stmts.add_result(conn, taskrun_id=taskrun_id, 
                         entity_code=entity_code, entity_text=p,
                         start_idx=start_idx, end_idx=end_idx)


run_id = stmts.add_run(conn, method_code='muckrock')
for task_id, doc_id, corpus, body in stmts.get_all_tasks(conn): 
    print(task_id, doc_id, corpus)
    taskrun_id = stmts.add_taskrun(conn, run_id=run_id, task_id=task_id)
    store_pii(taskrun_id, 'ssn', crim.ssn_numbers(body), body)
    store_pii(taskrun_id, 'phone_number', crim.phones(body), body)
    store_pii(taskrun_id, 'ban', crim.iban_numbers(body), body)
    store_pii(taskrun_id, 'credit_card', crim.credit_cards(body), body)
    store_pii(taskrun_id, 'email_address', crim.emails(body), body)
