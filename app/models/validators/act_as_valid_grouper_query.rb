# This module validates the attributes submitted by the form.
module ActAsValidGrouperQuery
  def self.included(base)
    base.validates :sex, :presence => true, inclusion: {in: lambda { |obj| WebgrouperPatientCase::SEX_MODES }}
    base.validates_date :entry_date, :on_or_before => :today, :allow_blank => true
    base.validates_date :exit_date, :on_or_before => :today, :on_or_after => :entry_date, :allow_blank => true
    base.validates_date :birth_date, :on_or_before => :entry_date, :allow_blank => true
    base.validates :leave_days, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
    base.validates :age, :presence => true, :numericality => {:only_integer => true, :greater_than => 0, :less_than => 125}, :unless => :age_mode_days?
    base.validates :age, :presence => true, :numericality => {:only_integer => true, :greater_than => 0, :less_than => 367}, :if => :age_mode_days?
    # Admission weight
    base.validates :adm_weight, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 125, :less_than_or_equal_to => 20000}, :if => :age_mode_days?
    # Admission mode
    base.validates :adm, :presence => true, inclusion: {in: lambda { |obj| WebgrouperPatientCase::ADMISSION_MODES }}
    # Separation mode
    base.validates :sep, :presence => true, inclusion: {in: lambda { |obj| WebgrouperPatientCase::SEPARATION_MODES }}
    # Length of stay
    base.validates :los, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
    # Artificial respiration time
    base.validates :hmv, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_blank => true
    # Main diagnosis
    base.validates :pdx, :presence => true, :existing_icd => true
    base.validates :diagnoses, :existing_icd => true, :length => {:maximum => 99}
    base.validates :procedures, :existing_chop => true, :length => {:maximum => 100}
  end

end
