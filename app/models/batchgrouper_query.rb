# For logging queries to the batchgrouper
class BatchgrouperQuery
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :ip, type: String
  field :first_line, type: String
  field :line_count, type: Integer
  field :time, type: Time

  index time: 1
end