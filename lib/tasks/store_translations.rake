
namespace :i18n do
  
  desc "Find and list translation keys that do not exist in all locales"
  task :missing_keys => :environment do
    finder = LocalchI18n::MissingKeysFinder.new(I18n.backend)
    finder.find_missing_keys
  end
  
  desc "Download translations from Google Spreadsheet and save them to YAML files."
  task :import_translations => :environment do
    raise "'Rails' not found! Tasks can only run within a Rails application!" if !defined?(Rails)
    
    config_file = Rails.root.join('config', 'translations.yml')
    raise "No config file 'config/translations.yml' found." if !File.exists?(config_file)
    
    tmp_dir = Rails.root.join('tmp')
    
    translations = LocalchI18n::Translations.new(config_file, tmp_dir)
    translations.download_files
    translations.store_translations
    translations.clean_up
    
  end
  
  # http://stackoverflow.com/questions/1357639/rails-rake-how-to-pass-in-arguments-to-a-task-with-environment
  desc "Export all language files to CSV files (only files contained in base folder are considered, default = en)"
  task :export_translations, [:base] => :environment do |t, args|
    raise "'Rails' not found! Tasks can only run within a Rails application!" if !defined?(Rails)
    
    args.with_defaults(:base => 'en')

    source_dir  = Rails.root.join('config', 'locales')
    output_dir  = Rails.root.join('tmp')
    locales     = I18n.available_locales
    
    input_files = Dir[File.join(source_dir, base_locale, '*.yml')]
    
    puts ""
    puts "  Detected locales: #{locales}"
    puts "  Detected files:"
    input_files.each {|f| puts "    * #{File.basename(f)}" }
    
    puts ""
    puts "  Start exporting files:"
    
    input_files.each do |file|
      file = File.basename(file)
      exporter = LocalchI18n::TranslationFileExport.new(source_dir, file, output_dir, locales)
      exporter.export
    end
    
    puts ""
    puts "  CSV files can be removed safely after uploading them manually to Google Spreadsheet."
    puts ""
  end
  
end


