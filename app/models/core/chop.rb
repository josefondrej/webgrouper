class CHOP
  include Mongoid::Document
	self.collection_name = "chop"
  
  field :code_short, type: String
  field :code, type: String
  field :description, type: String, localize: true
  field :icd_version, type: String
	
	default_scope lambda{where(:chop_version => System.current_system.chop_version)}
  
  def self.short_code_of(value)
    value.gsub(/\./, "").strip
  end
  
  # Returns the value as pretty code if it is available in the db.
  # Throws a Runtime Error if the given value is not valid.
  def self.pretty_code_of(value)
    db_entry = self.find_by(code_short: short_code_of(value))
    raise "'#{value}' is not a valid icd code" if db_entry.nil?
    db_entry.code
  end
  
  def autocomplete_result
    "#{self.code} #{self.description}"
  end
  
end