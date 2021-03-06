# encoding: UTF-8
# This class is used for creating a data chart containing all the
# length of stay data computed through the grouper.
# This uses a big deal of the google chart API
class LosDataTable < GoogleVisualr::DataTable
  def initialize(actual_los, cost_weight, weighting_relation, factor)
    super()
    new_columns [ {:type => 'number'},
                  {:type => 'number'},
                  {:type => 'string', :role => 'annotation'},
                  {:type => 'string', :role => 'annotationText'},
                  {:type => 'string', :role => 'tooltip'},
                  {:type => 'number'},
                  {:type => 'string', :role => 'annotation'},
                  {:type => 'string', :role => 'annotationText'},
                  {:type => 'string', :role => 'tooltip'},]

    # Values used for populating the rows of the table:
    avg_duration = weighting_relation.avg_duration.to_f/factor
    low_trim_point = weighting_relation.first_day_discount + 1
    high_trim_point = weighting_relation.first_day_surcharge - 1
    base_cost_rate = weighting_relation.cost_weight.to_f/factor
    effective_cost_weight = cost_weight.effective_cost_weight.to_f/factor
    discount_per_day = weighting_relation.discount_per_day.to_f/factor
    surcharge_per_day = weighting_relation.surcharge_per_day.to_f/factor

    one_day_cost_rate = base_cost_rate - discount_per_day*(low_trim_point - 1)
    # avg duration is needed here for drgs without high trim point
    many_days = [high_trim_point, actual_los, avg_duration].max + 5
    many_days_cost_rate = base_cost_rate + surcharge_per_day*(many_days - high_trim_point)
   
    rows = []
    # If it is a transferred case, we need to draw 2 lines. The actual los is
    # then suppposed to be on the second line.
    if cost_weight.case_flag == EffectiveCostWeight::CaseType::TRANSFERRED
      transfer_flatrate = weighting_relation.transfer_flatrate.to_f/factor    
      one_day_transfer_rate = base_cost_rate - transfer_flatrate*(avg_duration-1)
      avg_transfer_rate = base_cost_rate
      rows.push [actual_los, nil, nil, nil, 
                 nil,
                 effective_cost_weight, I18n.t('result.length-of-stay.length-of-stay-short'), 
                 I18n.t('result.length-of-stay.length-of-stay'), 
                 make_tooltip('length-of-stay', actual_los, effective_cost_weight)]
    else
      rows.push [actual_los, effective_cost_weight, I18n.t('result.length-of-stay.length-of-stay-short'), 
                 I18n.t('result.length-of-stay.length-of-stay'), 
                 make_tooltip('length-of-stay', actual_los, effective_cost_weight) , 
                 nil, nil, nil, 
                 nil]
    end
    
    rows.push [1, one_day_cost_rate, nil, nil, 
        nil, 
        one_day_transfer_rate, nil, nil, 
        nil]
    if weighting_relation.has_first_day_discount
      rows.push [low_trim_point, base_cost_rate, nil , I18n.t('result.length-of-stay.low_trim_point'),
        make_tooltip('low_trim_point', low_trim_point, base_cost_rate), 
        nil, nil, nil, 
        nil]
    end
    rows.push [avg_duration, base_cost_rate, 'Ø',I18n.t('result.length-of-stay.average_los'),
        make_tooltip('average_los', avg_duration, base_cost_rate), 
        avg_transfer_rate, 'Ø', I18n.t('result.length-of-stay.average_los'),
        make_tooltip('average_los', avg_duration, base_cost_rate)]
    # in case there is no first_day_surcharge, high trim point will be -1 here
    if weighting_relation.has_first_day_surcharge
      rows.push [high_trim_point, base_cost_rate, nil , I18n.t('result.length-of-stay.high_trim_point'),
          make_tooltip('high_trim_point', high_trim_point, base_cost_rate),
          nil, nil, nil,
          nil]
    end
    rows.push [many_days, many_days_cost_rate, nil, nil,
        nil, 
        nil, nil, nil, 
        nil]
    
    # Sort the rows afterwards, so the chart is not like spaghetti
    sorted_rows = rows.sort_by { |row| row[0] }
    
    add_rows(sorted_rows)
  end
  
  # Gives back a chart, using the data filled in this instance.
  def make_chart()
    options = { :width => 650, :height => 170,
                :legend => 'none',
                :interpolateNulls => true,
                #:chartArea => { :width => "100%", :height => "100%" },
                :hAxis => { :gridlines => { :count => 10} ,
                            :title => I18n.t('datetime.distance_in_words.x_days', :count => '') },
                :vAxis => { :title => I18n.t('result.cost-weight.legend') } ,
                :allowHtml => "true" }
    GoogleVisualr::Interactive::LineChart.new(self, options)
  end
  
  #TODO: values should to be bold
  # Gives back a formatted string with the data given
  def make_tooltip(x_value_caption, x_value, y_value)
    "#{I18n.t('result.length-of-stay.' + x_value_caption)}: " +
        "#{I18n.t('datetime.distance_in_words.x_days', :count => x_value.to_s)} \n" +
        "#{I18n.t('result.cost-weight.legend')}: #{y_value.to_s}"
  end
end