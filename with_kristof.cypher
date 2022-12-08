//reminder
//match(n:Patient:NoT2D)  set n.targetProperty =0;
//match(n:Patient:T2D)  set n.targetProperty =1;

//12 members (have 1 property less hba1c)
//match(p:Patient:NoHbA1c) set p.isTrain = 0 
// 51 members
//match(p:Patient) where not p:NoHbA1c set p.isTrain = 1 

CALL gds.graph.project(
    'graph',                                                                                
    ['Patient','Transcript']  
    ,
    {MEASURED: {orientation: 'REVERSE'}},
    {relationshipProperties: ['value']}                           
)
YIELD graphName, nodeProjection, nodeCount AS nodes, relationshipCount AS rels
RETURN graphName, nodeProjection.Patient AS patientProjection, nodes, rels;

CALL gds.nodeSimilarity.write('graph', {
    similarityCutoff: 0.9708,
    writeRelationshipType: 'SIMILAR',
    writeProperty: 'similarityScore'
});

CALL gds.graph.project(
    'graph2',                                                                                
    ['Patient']  
    ,
    {SIMILAR: {orientation: 'UNDIRECTED'}},
    {relationshipProperties: ['similarityScore']}                         
);

CALL gds.fastRP.write('graph2',{
    relationshipTypes:['SIMILAR'],
    embeddingDimension: 128,
    iterationWeights: [0, 0, 1.0, 1.0],
    normalizationStrength:0.05,
    writeProperty: 'fastRP__Embed'
})

// project graph for node classification
CALL gds.graph.project(
    'graph3',   {                                                                               
    Patient: {properties: {
        targetProperty:{property:'targetProperty',defaultValue:0},
        isTrain:{property:'isTrain',defaultValue:0},
        fastRP__Embed:{property:'fastRP__Embed'}
        }
      }  
}
    ,
    {SIMILAR: {orientation: 'UNDIRECTED'}},
    {relationshipProperties: ['similarityScore']}                         
);

CALL gds.beta.pipeline.nodeClassification.create('pipe');

CALL gds.beta.pipeline.nodeClassification.selectFeatures('pipe', ['fastRP__Embed'])
YIELD name, featureProperties;

CALL gds.beta.pipeline.nodeClassification.configureSplit('pipe', {
  testFraction: 0.2,
   validationFolds: 5
 })
 YIELD splitConfig;

CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('pipe', {penalty: 0.0625}) YIELD parameterSpace;

// Training graph
CALL gds.beta.graph.project.subgraph('graph-train', 'graph3', 'n:Patient AND n.isTrain = 1', '*')
    YIELD graphName, fromGraphName, nodeCount, relationshipCount;

// Test graph
CALL gds.beta.graph.project.subgraph('graph-test', 'graph3', 'n:Patient AND n.isTrain = 0', '*')
    YIELD graphName, fromGraphName, nodeCount, relationshipCount;

// train model
CALL gds.beta.pipeline.nodeClassification.train('graph-train', {
  pipeline: 'pipe',
  targetNodeLabels: ['Patient'],
  modelName: 't2d_FRP',
  targetProperty: 'targetProperty',
  randomSeed: 42,
  metrics: ['F1_WEIGHTED','ACCURACY']
}) ;

// now predict
CALL gds.beta.pipeline.nodeClassification.predict.mutate('graph-test', {
      targetNodeLabels: ['Patient'],
      modelName: 't2d_FRP',
      mutateProperty: 'predicted_t2d'
});

CALL gds.graph.writeNodeProperties(
      'graph-test',
      ['predicted_t2d'],
      ['Patient']
);


// check accuracy
MATCH (p:Patient)
WHERE p.isTrain = 0
WITH count(p) AS nbPatient
MATCH (p:Patient)
WHERE p.isTrain = 0
AND p.targetProperty = p.predicted_t2d
RETURN toFloat(count(p)) / nbPatient AS ratio;