Feature: Enterin Simones data should work
  Simone
  Should group without any conflicts and validation errors, when entering her case
  
  @javascript
  Scenario: A random valid patient case
    Given the form with initialized standard values
    When I enter "N28.0" as diagnosis
    And I enter "38.36.15" as procedure

    And I press on "Fall Gruppieren"
    Then the grouping should succeed
    And I should see "11" in "grouping"
    And I should see "Andere Eingriffe bei Erkrankungen der Harnorgane, Alter > 1 Jahr, ohne äusserst schwere CC" in "grouping"
    And I should see "L09B" in "grouping"
    And I should see "0.937" in "cost-weight"
    And I should see "N28.0" in "result-diagnoses"
    And I should see "38.36.15" in "result-procedures"
    And I should see "Ischämie und Infarkt der Niere" in "result-diagnoses"
