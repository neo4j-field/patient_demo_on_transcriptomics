// load csv data lipidomics part
CALL apoc.load.csv('brca_matrix.csv', {header:false, sep:',',quoteChar:'"', limit:1}) 
    YIELD lineNo, map as row , list
unwind list as l with l skip 1
MERGE(p:Patient{patient_id:l, source:'lididr'});

// Create Lipids
CALL apoc.load.csv('brca_matrix.csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as row , list
    MERGE(n:Lipid{name:row['lipids'], source:'lididr'});
// Connect patients with measured lipids
CALL apoc.load.csv('brca_matrix.csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as dict , list
    WITH keys(dict) as patients, dict 
    UNWIND patients as patient 
    MATCH (p:Patient{patient_id:patient}),(l:Lipid{name:dict["lipids"]})
    WHERE dict[patient] is not null
    MERGE (p)<-[:MEASURED{value:toFloat(dict[patient])}]-(l);

// load clinical data part
CALL apoc.load.csv('brca_clin.csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as dict , list
    //WITH keys(dict) as dict 
    //UNWIND patients as patient 
    MATCH (p:Patient{patient_id:dict['Sample']})
    SET p.sampletype = dict['SampleType'], p.race = dict['Race'], p.stabe = dict['Stage'], p.tumortype =dict['Tumor.Type'] , p.source = 'lididr';
