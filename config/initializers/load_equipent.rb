equipment_file = Rails.root.join('config/equipment_list.yml')

if File.exist?(equipment_file)
  EQUIPMENT_LIST = YAML.load_file(equipment_file) || []
else
  EQUIPMENT_LIST = []
end
