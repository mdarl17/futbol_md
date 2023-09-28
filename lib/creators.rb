require_relative 'stat_tracker'

module Creators

  def create_games(path)
    data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
    data.map do |row|
      Game.new(row)
    end
  end

  def create_game_teams(path)
    data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
    data.map do |row| 
      GameTeam.new(row)
    end
  end

  def create_teams(path)
    data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
    data.map do |row|
      Team.new(row)
    end
  end

  def self.from_csv(locations)
    StatTracker.new(locations)
  end
end