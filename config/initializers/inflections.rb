# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
#
# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular /^(.*)en$/i, '\1'                        # "Konkneipanten" => "Konkneipant"
  inflect.singular /^(.*)e (.*)en$/i, '\1er \2'             # "Aktive Burschen" => "Aktiver Bursch"
  inflect.singular /^(.*)e (.*)en (.*)$/i, '\1er \2 \3'     # "Inaktive Burschen loci" => "Inaktiver Bursch loci"
  inflect.singular /^(.*)ene$/, '\1ener'                    # "Ausgetretene" => "Ausgetretener"
  inflect.singular /^(.*)te$/, '\1ter'                      # "Chargierte" => "Chargierter"
  inflect.irregular 'aktivitas', 'aktivitates'
  inflect.irregular 'philisterschaft', 'philisterschaften'
  inflect.uncountable 'wingolf'
end
