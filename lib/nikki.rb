require 'thor'
require 'pathname'
require 'yaml/store'
require 'date'
require 'fileutils'

# @author Brandon Pittman
# This is the main class that interfaces with Thor's methods and does all the
# heavy lifting for Nikki.  It's a bit of a "God" object. Sorries.
class Generator < Thor
  FileUtils.mkdir_p("#{ENV['HOME']}/.config/nikki")
  NIKKI_FILE = "#{ENV['HOME']}/.config/nikki/nikki.yaml".freeze

  # @!group Data entry
  desc 'new ENTRY', 'Creates a new entry in the Nikki journal.'
  # Add entry to journal
  # @param entry [String] entry to add to the journal
  # @param update [String] International date for update
  # @return [Hash] Returns a Hash which is then saved in a YAML file.
  # @example
  #   "nikki new 'This is a thing I learned today!'"
  # Reads the settings in from the config YAML file and changes the
  # date updated.  It does the same with the journal file, reading in the YAML
  # and merging the hash of entries, and then saves the YAML back again.
  def new(entry, date = Date.today)
    YAML::Store.new("#{ENV['HOME']}/.nikki/nikki.yaml").transaction do |store|
      store['entries'] << { date => entry.strip }
    end

    ls
  end

  desc 'missed', 'Create new entry for yesterday'
  # Creates a new entry for yesterday
  # @param entry [String]
  # @since 0.5.3
  def missed(entry)
    new(entry, (Date.today - 1))
  end
  # @!endgroup

  desc 'open', "Open current year's journal file in editor."
  # Open Nikki journal in configured text editor
  def open
    system(ENV['EDITOR'], NIKKI_FILE)
  end

  desc 'ls', 'Displays latest Nikki entries.'
  # Display Nikki's latest entires
  # @return [String]
  # @option options :sticky [String]
  def ls
    YAML::Store.new(NIKKI_FILE).transaction do |store|
      entries = store['entries'].last(5)
      entries.each do |entry|
        entry.each do |date, text|
          puts "#{date}: #{text}"
        end
      end
    end
  end

  desc 'export YEAR', 'Export Nikki journal from YEAR as YAML'
  # @param [String] year of journal entries you wish to export
  def export(export_year)
    YAML::Store.new(NIKKI_FILE).transaction do |store|
      store['entries'].each do |entry|
        if entry.keys[0].year.to_s == export_year
          puts "#{entry.keys[0]}: #{entry.values[0]}"
        end
      end
    end
  end
end
