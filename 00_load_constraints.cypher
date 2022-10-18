CREATE CONSTRAINT patientNumber IF NOT EXISTS for (n:Patient) REQUIRE n.patient_id is UNIQUE;
CREATE CONSTRAINT Transcript IF NOT EXISTS for (n:Transcript) REQUIRE n.name is UNIQUE;
CREATE CONSTRAINT Lipid IF NOT EXISTS for (n:Lipid) REQUIRE n.name is UNIQUE;