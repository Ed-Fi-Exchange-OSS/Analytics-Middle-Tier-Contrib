# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

def question_marks(number_of_question_marks=0):
    counter = 0
    concatenation = ''
    if number_of_question_marks != 0:
        while counter < number_of_question_marks:
            concatenation = concatenation + '?,'
            counter = counter + 1
        return concatenation[:-1]
    return ''
