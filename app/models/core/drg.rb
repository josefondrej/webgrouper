class Drg
  include Mongoid::Document
  
  field :code, type: String
  field :text, type: String, localize: true
  field :cost_weight, type: Float
  field :avg_duration, type: Float
  field :first_day_discount, type: Integer
  field :discount_per_day, type: Float
  field :first_day_surcharge, type: Integer
  field :surcharge_per_day, type: Float
  field :transfer_flatrate, type: Float
  field :exception_from_reuptake_flag, type: Boolean
  field :version, type: String
  field :partition, type: String
  field :birthhouse, type: Boolean
  field :nonvaluated, type: Boolean
  field :drg_type, type: Integer
  
  scope :in_system, lambda { |system_id| where(:version => System.where(:system_id => system_id ).first.drg_version) }
	scope :in_birthhouse_system, lambda { |system_id| where(:version => System.where(:system_id => system_id ).first.drg_version + "_birthhouse")}
	def self.get_description_for(system_id, search_code)
    find_by_code(system_id, search_code).text
  end
  
  def self.reuptake_exception?(system_id, search_code)
    find_by_code(system_id, search_code).exception_from_reuptake_flag
  end
  
  def self.find_by_birthhouse_code(system_id, search_code)
    raise 'No code given' if search_code.blank?
    in_birthhouse_system(system_id).where(code: search_code).first
  end
  
  def self.find_by_code(system_id, search_code)
    raise 'No code given' if search_code.blank?
    in_system(system_id).where(code: search_code).first
  end

  # Returns true if there is no transfer flatrate
  def transfer_flag()
    transfer_flatrate.nil? or transfer_flatrate == 0
  end

  index({code: 1, version: 1}, {:unique => true})

end
