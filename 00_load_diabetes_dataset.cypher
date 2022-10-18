
// Diabetes dataset
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
    SET p.source = 'diabetes.csv';