module PatientCasesHelper
  
  def procedure_values(patient_case, field_counter)
    compressed_procedure = patient_case.procedures[field_counter]
    procedures = compressed_procedure.split("$") unless compressed_procedure.nil?
    procedures
  end
end
