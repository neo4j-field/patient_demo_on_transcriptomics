CREATE CONSTRAINT patientNumber for (n:Patient) REQUIRE n.patient_id is UNIQUE;
CREATE CONSTRAINT Transcript for (n:Transcript) REQUIRE n.name is UNIQUE;
CREATE CONSTRAINT Lipid for (n:Lipid) REQUIRE n.name is UNIQUE;


# CREATE patient nodes
CALL apoc.load.csv('GDS5167_noMetadata.csv', {header:false, sep:'TAB', nullValues:['null'], limit:1}) 
    YIELD lineNo, map as row , list
UNWIND list as p
with p skip 2 
CREATE(pa:Patient{patient_id:p});
# CREATE Transcript nodes
CALL apoc.load.csv('GDS5167_noMetadata.csv', {header:true, sep:'TAB', nullValues:['null']}) 
    YIELD lineNo, map as row, list
CREATE(tr:Transcript{name:row['ID_REF']});
# CREATE relationships
CALL apoc.periodic.iterate('
CALL apoc.load.csv("GDS5167_noMetadata.csv", {header:true, sep:"TAB", nullValues:["null"]}) 
    YIELD lineNo, map as dict, list
    WITH keys(dict) as patients, dict 
    UNWIND patients as patient
    
    MATCH (p:Patient{patient_id:patient}),(tr:Transcript{name:dict["ID_REF"]}) 
    WHERE dict[patient] is not null
    RETURN p, tr, dict[patient] as value'
     //return p.patient_id as patientNO, dict['ID_REF'] as transcript, dict[patient]
     ,"CREATE(p)<-[:MEASURED{value:toFloat(value)}]-(tr)",
     {batchsize:10000}
)

# load csv data lipidomics
CALL apoc.load.csv('brca_matrix.csv', {header:false, sep:',',quoteChar:'"', limit:1}) 
    YIELD lineNo, map as row , list
unwind list as l with l skip 1
CREATE(p:Patient{patient_id:l})

# Create Lipids
CALL apoc.load.csv('brca_matrix.csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as row , list
    MERGE(n:Lipid{name:row['lipids']})
# Connect patients with measured lipids
CALL apoc.load.csv('brca_matrix.csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as dict , list
    WITH keys(dict) as patients, dict 
    UNWIND patients as patient 
    MATCH (p:Patient{patient_id:patient}),(l:Lipid{name:dict["lipids"]})
    WHERE dict[patient] is not null
    MERGE (p)<-[:MEASURED{value:toFloat(dict[patient])}]-(l)

CALL apoc.load.csv('brca_clin.csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as dict , list
    //WITH keys(dict) as dict 
    //UNWIND patients as patient 
    MATCH (p:Patient{patient_id:dict['Sample']})
    SET p.sampletype = dict['SampleType'], p.race = dict['Race'], p.stabe = dict['Stage'], p.tumortype =dict['Tumor.Type']

# Diabetes dataset
CALL apoc.load.csv('diabetes.csv', {header:true, sep:',',quoteChar:'"'}) 
    YIELD lineNo, map as dict , list
    //WITH keys(dict) as dict 
    //UNWIND patients as patient 
    CREATE (p:Patient) 
    SET p.bloodPressure = dict['BloodPressure']
    SET p.skinThickness = dict['SkinThickness']
    SET p.pregnancies = dict['Pregnancies']
    SET p.glucose = dict['Glucose']
    SET p.insulin = dict['Insulin']
    SET p.bmi = dict['BMI']
    SET p.diabetesPedigreeFunction = dict['DiabetesPedigreeFunction']
    SET p.age = dict['Age']
    SET p.outcome = dict['Outcome']
    SET p.dataset = 'diabetes.csv'

# Indian Liver Patient dataset
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
    SET p.dataset = 'Indian Liver Patient Dataset (ILPD).csv'

# Load GDS 4337 dataset
CALL apoc.load.csv('GDS4337.soft', {header:false, sep:'TAB',quoteChar:'"', nullValues:['null'], skip:216 }) 
    YIELD lineNo, map as dict , list
    with list limit 1
    unwind list as pId
    MERGE(p:Patient{patient_id:pId});
CALL apoc.load.csv('GDS4337.soft', {header:false, sep:'TAB',quoteChar:'"', nullValues:['null'], skip:216 }) 
    YIELD lineNo, map as dict , list
    CREATE(tr:Transcript{name:dict['ID_REF'], synonym:dict['IDENTIFIER']});

# GDS 
# Create Graph catalog
CALL gds.graph.project(
    'graph',                                                                                
    ['Patient','Transcript']  
    ,
    {MEASURED: {orientation: 'REVERSE'}},
    {relationshipProperties: ['value']}                           
)
YIELD graphName, nodeProjection, nodeCount AS nodes, relationshipCount AS rels
RETURN graphName, nodeProjection.Patient AS patientProjection, nodes, rels

# Calculating NodeSimilarity between patients in streaming mode
CALL gds.nodeSimilarity.stream('graph', { relationshipWeightProperty: 'value', similarityCutoff: 0.5 })
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).patient_id AS Person1, gds.util.asNode(node2).patient_id AS Person2, similarity
ORDER BY Person1

# Calculating NodeSimilarity between patients writing back mutateProperty
CALL gds.nodeSimilarity.mutate('graph', { relationshipWeightProperty: 'value', similarityCutoff: 0.5, mutateProperty:'similarity', mutateRelationshipType:'IS_SIMILAR' })

# fastRP
CALL gds.fastRP.stream(
    'graph',
    {
        embeddingDimension: 10,
        randomSeed: 256,
        relationshipWeightProperty: 'value'
    }
)
YIELD nodeId, embedding