# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import pandas as pd
from common.helpers import question_marks


def preparation_process(conn_target) -> None:

    cursor_target = conn_target.cursor()
    
    print("Delete data from FactK12StudentEnrollments...", end='')
    cursor_target.execute("DELETE FROM RDS.FactK12StudentEnrollments")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.FactK12StudentEnrollments', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from FactK12ProgramParticipations...", end='')
    cursor_target.execute("DELETE FROM RDS.FactK12ProgramParticipations")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.FactK12ProgramParticipations', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimDataCollections...", end='')
    cursor_target.execute("DELETE FROM RDS.DimDataCollections;")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimDataCollections', RESEED, 0);")
    print("Done!\n", end='')

    print("Delete data from DimSeas...", end='')
    cursor_target.execute("DELETE FROM RDS.DimSeas")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimSeas', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimSchoolYears...", end='')
    cursor_target.execute("DELETE FROM RDS.DimSchoolYears")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimSchoolYears', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimRaces...", end='')
    cursor_target.execute("DELETE FROM RDS.DimRaces")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimRaces', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimLeas...", end='')
    cursor_target.execute("DELETE FROM RDS.DimLeas")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimLeas', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimK12Students...", end='')
    cursor_target.execute("DELETE FROM RDS.DimK12Students")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimK12Students', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimK12Schools...", end='')
    cursor_target.execute("DELETE FROM RDS.DimK12Schools")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimK12Schools', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimK12ProgramTypes...", end='')
    cursor_target.execute("DELETE FROM RDS.DimK12ProgramTypes")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimK12ProgramTypes', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimK12EnrollmentStatuses...", end='')
    cursor_target.execute("DELETE FROM RDS.DimK12EnrollmentStatuses")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimK12EnrollmentStatuses', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimK12Demographics...", end='')
    cursor_target.execute("DELETE FROM RDS.DimK12Demographics")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimK12Demographics', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimIeus...", end='')
    cursor_target.execute("DELETE FROM RDS.DimIeus")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimIeus', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimIdeaStatuses...", end='')
    cursor_target.execute("DELETE FROM RDS.DimIdeaStatuses")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimIdeaStatuses', RESEED, 0);")
    print("Done!\n", end='')
    
    print("Delete data from DimGradeLevels...", end='')
    cursor_target.execute("DELETE FROM RDS.DimGradeLevels")
    cursor_target.execute("DBCC CHECKIDENT ('RDS.DimGradeLevels', RESEED, 0);")
    print("Done!\n", end='')

    conn_target.commit()

