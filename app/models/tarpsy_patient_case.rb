class TarpsyPatientCase
  include Mongoid::Document
  include Mongoid::Timestamps

  field :entry_date, type: Date
  field :exit_date, type: Date
  field :leave_days, type: Integer, default: 0
  field :los, type: Integer, default: 10
  field :pdx, type: String

  # For logging
  field :ip, type: String
  field :randomly_generated, type: Boolean, default: false

  embeds_many :assessments
  embeds_many :icds
  belongs_to :system, class_name: 'TarpsySystem', primary_key: :system_id

  accepts_nested_attributes_for :assessments
  after_initialize :set_defaults

  validates_presence_of :pdx, :entry_date, :assessments
  validates_date :entry_date, on_or_before: :today
  validates_date :exit_date, on_or_after: :entry_date,
                             on_or_before: :today
  validates :pdx, existing_icd: true
  validates :assessments, assessments: true, unless: lambda { entry_date.blank? || assessments.blank? }
  java_import org.swissdrg.grouper.tarpsy.TARPSYPatientCase
  java_import org.swissdrg.grouper.Diagnosis

  GROUPER_DATE_FORMAT = "%Y%m%d"

  attr_accessor :pc_java

  def to_java
    pc_java = TARPSYPatientCase.new
    pc_java.entry_date = entry_date.strftime(GROUPER_DATE_FORMAT) unless entry_date.blank?
    pc_java.exit_date = exit_date.strftime(GROUPER_DATE_FORMAT) unless exit_date.blank?
    pc_java.pdx = Diagnosis.new(pdx)

    # Turn each assessment hash into an assessment object and add it to pc.
    assessments.each do |a|
      pc_java.add_assessment(a.to_java)
    end
    pc_java
  end

  # TODO: Create url format and allow parsing it.
  def to_url_string
    pc_java.to_s
  end

  private

  def set_defaults
    self.system_id ||= TarpsySystem::DEFAULT_SYSTEM_ID
    self.assessments.reject! { |a| a.date.blank? and a.assessment_items.all? { |i| i.blank? || i.value == 9 } }
    self.assessments.sort! {|a,b| a.date && b.date ? a.date <=> b.date : a.date ? -1 : 1 }
  end

end