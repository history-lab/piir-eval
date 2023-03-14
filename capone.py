import os
import dataprofiler as dp
from dblib import conn, stmts

# data profiler related configuration
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # disable TensorFlow info msgs
redacted = ['SSN', 'PHONE_NUMBER', 'BAN', 'CREDIT_CARD', 'DRIVERS_LICENSE']
dl = dp.DataLabeler(labeler_type='unstructured')
# set the output to the NER format (start position, end position, label)
dl.set_params(
    {'postprocessor': {'output_format': 'ner',
                       'use_word_level_argmax': True}})

def dp_run(doctext):
    # find the PII using the built-in Data Profiler model
    results = dl.predict(doctext)
    return results['pred'][0]

# test_id, doc_id, corpus, body = stmts.get_all_tests(conn)[0]
run_id = stmts.add_run(conn, method_code='capone')
for test_id, doc_id, corpus, body in stmts.get_all_tests(conn):
    testrun_id = stmts.add_testrun(conn, run_id=run_id, test_id=test_id) 
    print(test_id, doc_id, corpus)
    # print(body)
    all_labels = dp_run([body])
    redact_labels = list(filter(lambda l: l[2] in redacted, all_labels))
    for r in redact_labels:
        start_idx, end_idx, entity_code = r[0], r[1], r[2].lower()
        entity_text = body[start_idx:end_idx]
        print(f'{entity_code=}, {start_idx=}, {end_idx=}')
        stmts.add_result(conn, testrun_id=testrun_id, 
                          entity_code=entity_code, entity_text=entity_text,
                          start_idx=start_idx, end_idx=end_idx)
    print('\n' * 2)