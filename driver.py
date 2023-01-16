import os
import psycopg2
import aiosql
import dataprofiler as dp


# db-related configuration
conn = psycopg2.connect("")
conn.autocommit = True
stmts = aiosql.from_path("driver.sql", "psycopg2")

# data profiler related configuration
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # disable TensorFlow info msgs
redacted = ['SSN', 'BAN', 'CREDIT_CARD', 'UUID', 'DRIVERS_LICENSE']
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
for test_id, doc_id, corpus, body in stmts.get_all_tests(conn):
    print(test_id, doc_id, corpus)
    print(body)
    all_labels = dp_run([body])
    redact_labels = list(filter(lambda l: l[2] in redacted, all_labels))
    print(redact_labels)
    print('\n' * 2)