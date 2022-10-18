// Indian Liver Patient dataset
CALL apoc.load.csv('Indian Liver Patient Dataset (ILPD).csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as dict , list
    CREATE (p:Patient)
    SET p.patient_id = lineNo
    SET p.is_patient = dict['is_patient']
    SET p.gender = dict['gender']
    SET p.direct_bilirubin = dict['direct_bilirubin']
    SET p.ag_ratio = dict['ag_ratio']
    SET p.albumin = dict['albumin']
    SET p.tot_bilirubin = dict['tot_bilirubin']
    SET p.tot_proteins = dict['tot_proteins']
    SET p.sgot = dict['sgot']
    SET p.alkphos = dict['alkphos']
    SET p.sgpt = dict['sgpt']
    SET p.age = dict['age']
    SET p.source = 'Indian Liver Patient Dataset (ILPD).csv';