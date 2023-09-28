require './spec/spec_helper'

RSpec.describe StatTracker do
  before(:all) do
    # game_path =         './fixture/games_fixture.csv'
    # team_path =         './data/teams.csv'
    # game_teams_path = './fixture/game_teams_fixture.csv'
    game_path = './data/games.csv'
    team_path = './data/teams.csv'
    game_teams_path =   './data/game_teams.csv'

    locations = {
      games:            game_path,
      teams:            team_path,
      game_teams:       game_teams_path
    }

    @stat_tracker = StatTracker.new(locations)
  end

  describe '#Total Scores' do
    it "returns the highest total score" do
      expect(@stat_tracker.highest_total_score).to eq 11
    end
  
    it "returns the lowest total score" do
      expect(@stat_tracker.lowest_total_score).to eq 0
    end
  end

  describe '#percentage of wins, ties, and losses' do
    it "returns the percentage of home wins" do
      expect(@stat_tracker.percentage_home_wins).to eq 0.44
    end

    it "returns the percentage of visitor wins" do
      expect(@stat_tracker.percentage_visitor_wins).to eq 0.36
    end

    it "returns percentage of ties" do
      expect(@stat_tracker.percentage_ties).to eq 0.20
    end
  end

  describe '#count of games by season' do
    it "counts the games in each season" do
      expected = {
        "20122013"=>806,
        "20162017"=>1317,
        "20142015"=>1319,
        "20152016"=>1321,
        "20132014"=>1323,
        "20172018"=>1355
      }
      expect(@stat_tracker.count_of_games_by_season).to eq expected
    end
  end

  describe '#averages' do
    it "returns the average goals per game" do
      expect(@stat_tracker.average_goals_per_game).to eq 4.22
    end

    it "returns the average goals by season" do
      expected = {
        "20122013"=>4.12,
        "20162017"=>4.23,
        "20142015"=>4.14,
        "20152016"=>4.16,
        "20132014"=>4.19,
        "20172018"=>4.44
      }
      expect(@stat_tracker.average_goals_by_season).to eq expected
    end
  end

  describe '#team info' do
    it "returns a count of all the teams" do
      expect(@stat_tracker.count_of_teams).to eq 32
    end

    it "returns the team with the best offense" do
      expect(@stat_tracker.best_offense).to eq "Reign FC"
    end

    it "returns the team with the worst offense" do
      expect(@stat_tracker.worst_offense).to eq "Utah Royals FC"
    end

    it "returns the highest scoring visitor" do
      expect(@stat_tracker.highest_scoring_visitor).to eq "FC Dallas"
    end

    it "returns the highest scoring home team" do
      expect(@stat_tracker.highest_scoring_home_team).to eq "Reign FC"
    end

    it "returns the lowest scoring visitor" do
      expect(@stat_tracker.lowest_scoring_visitor).to eq "San Jose Earthquakes"
    end

    it "lowest_scoring_home_team" do
      expect(@stat_tracker.lowest_scoring_home_team).to eq "Utah Royals FC"
    end

    it "get_team_info" do
      expected = {
        "team_id" => "18",
        "franchise_id" => "34",
        "team_name" => "Minnesota United FC",
        "abbreviation" => "MIN",
        "link" => "/api/v1/teams/18"
      }

      expect(@stat_tracker.get_team_info("18")).to eq expected
    end

    xit "best_season" do
      expect(@stat_tracker.best_season("6")).to eq "20132014"
    end

    xit "worst_season" do
      expect(@stat_tracker.worst_season("6")).to eq "20142015"
    end

    xit "average_win_percentage" do
      expect(@stat_tracker.average_win_percentage("6")).to eq 0.49
    end

    xit "most_goals_scored" do
      expect(@stat_tracker.most_goals_scored("18")).to eq 7
    end

    xit "fewest_goals_scored" do
      expect(@stat_tracker.fewest_goals_scored("18")).to eq 0
    end

    xit "favorite_opponent" do
      expect(@stat_tracker.favorite_opponent("18")).to eq "DC United"
    end

    xit "rival" do
      expect(@stat_tracker.rival("18")).to eq("Houston Dash").or(eq("LA Galaxy"))
    end
  end

  describe '#coaches' do
    it "returns the most winningest coach in a season" do
      expect(@stat_tracker.winningest_coach("20132014")).to eq "Claude Julien"
      expect(@stat_tracker.winningest_coach("20142015")).to eq "Alain Vigneault"
    end

    it "returns the worst coach in a season" do
      expect(@stat_tracker.worst_coach("20132014")).to eq "Peter Laviolette"
      expect(@stat_tracker.worst_coach("20142015")).to eq("Craig MacTavish").or(eq("Ted Nolan"))
    end
  end

  describe '#team accuracy' do
    it "returns the most accurate team in a season" do
      expect(@stat_tracker.most_accurate_team("20132014")).to eq "Real Salt Lake"
      expect(@stat_tracker.most_accurate_team("20142015")).to eq "Toronto FC"
    end

    it "returns the least accurate team in a season" do
      expect(@stat_tracker.least_accurate_team("20132014")).to eq "New York City FC"
      expect(@stat_tracker.least_accurate_team("20142015")).to eq "Columbus Crew SC"
    end
  end

  describe '#team tackles' do
    it "returns the team with the most tackles in a season" do
      expect(@stat_tracker.most_tackles("20132014")).to eq "FC Cincinnati"
      expect(@stat_tracker.most_tackles("20142015")).to eq "Seattle Sounders FC"
    end

    it "returns the team with the fewest tackles in a season" do
      expect(@stat_tracker.fewest_tackles("20132014")).to eq "Atlanta United"
      expect(@stat_tracker.fewest_tackles("20142015")).to eq "Orlando City SC"
    end
  end

  describe "#percentage_calculator" do
    it "returns the percentage for given numbers rounded to nearest 100th" do
      expect(@stat_tracker.percentage_calculator(13.0, 19.0)).to eq(0.68)
      expect(@stat_tracker.percentage_calculator(5.0, 19.0)).to eq(0.26)
      expect(@stat_tracker.percentage_calculator(1.0, 19.0)).to eq(0.05)
    end
  end

  describe "#games_by_team" do 
    it 'will find the amount of home games per team' do
      expect(@stat_tracker.games_by_team("home")).to be_instance_of(Hash)
      expect(@stat_tracker.games_by_team("home")).to eq({"3"=>265, "6"=>257, "5"=>278, "17"=>242, "16"=>268, "9"=>245, "8"=>249, "30"=>250, "26"=>255, "19"=>253, "24"=>264, "2"=>240, "15"=>264, "20"=>236, "14"=>263, "28"=>258, "4"=>238, "21"=>236, "25"=>239, "13"=>232, "18"=>256, "10"=>238, "29"=>237, "52"=>240, "54"=>51, "1"=>231, "23"=>234, "12"=>229, "27"=>65, "7"=>229, "22"=>235, "53"=>164})
    end
  end
  
  describe "#highest_scoring_visitor" do
    it 'returns team with highest average score when away' do
      expect(@stat_tracker.highest_scoring_visitor).to eq "FC Dallas"
    end
  end

  describe "#find_game_with_season_id" do
    it "returns array with games of a season" do
      expect(@stat_tracker.find_game_with_season_id("20142015")).to be_instance_of(Array)
    end
  end

  describe '#helper methods' do
    it 'returns the team ids in a hash' do
      expect(@stat_tracker.team_info).to be_a(Hash)
      expect(@stat_tracker.team_info.keys.count).to eq 32
    end

    it 'finds games with season id in a season' do
      expect(@stat_tracker.find_game_with_season_id("20142015")).to be_instance_of(Array)
      expect(@stat_tracker.find_game_with_season_id("20142015").count).to eq 1319
    end

    it 'Game class returns array of games' do
      expect(Game.games).to be_instance_of(Array)
      expect(Game.games.count).to eq 7441
    end

    it 'GameTeam class returns array of gameteams' do
      expect(GameTeam.gameteam).to be_instance_of(Array)
      expect(GameTeam.gameteam.count).to eq 14882
    end
  end
end
# Group Tests
# ==========================================================================================================

#   describe "#percent ties" do
#     it "finds percentage of tied away and home games" do
#       expect(@gstat_tracker.percentage_ties).to eq(0.20)
#     end
#   end

#   

#   

#   it "#percentage_visitor_wins" do 
#     expect(@game_stats.percentage_visitor_wins).to eq 0.0
#   end


#   describe "#percentage_calculator" do
#     it "finds the percentage for given numbers rounded to nearest 100th" do
#       expect(@game_stats.percentage_calculator(13.0, 19.0)).to eq(0.68)
#       expect(@game_stats.percentage_calculator(5.0, 19.0)).to eq(0.26)
#       expect(@game_stats.percentage_calculator(1.0, 19.0)).to eq(0.05)
#     end
#   end
    
#     it 'helper methods' do
#       expect(@game_stats.seasons_sorted).to be_a(Hash)
#       expect(@game_stats.team_info).to be_a(Hash)
#       expect(@game_stats.most_tackles("20122013")).to eq "FC Dallas"
#       expect(@game_stats.fewest_tackles("20122013")).to eq "Chicago Fire"
#     end

#   xdescribe '#Tackles' do
#     it 'finds most number of tackles' do
#     #full data test
#       expect(@game_stats.most_tackles("20132014")).to eq "FC Cincinnati"
#       expect(@game_stats.most_tackles("20142015")).to eq "Seattle Sounders FC"
#   end
#     #full data test
#     it 'finds least number of tackles' do
#       expect(@stat_tracker.fewest_tackles("20132014")).to eq "Atlanta United"
#       expect(@stat_tracker.fewest_tackles("20142015")).to eq "Orlando City SC"
#     end
#   end

#   describe "#average_goals_per_game" do

#     xit 'will find the average goals' do

#     it 'will find the average goals' do
#       #this test is for the fixture

#       expect(@game_stats.average_goals_per_game).to eq(3.67)
#       #this test is for the full data
#       expect(@game_stats.average_goals_per_game).to eq(4.22)
#     end
#   end

  # describe "#team_goals" do 
  #   it 'will find the amount of goals per team' do
  #     expect(@game_stats.team_goals("home")).to be_instance_of(Hash)
  #     #this test is for the fixture
  #     require 'pry'; binding.pry
  #     expect(@game_stats.team_goals("away")).to eq({"3"=>5, "6"=>12, "5"=>1, "17"=>3, "16"=>1})
  #     expect(@game_stats.team_goals("home")).to eq({"3"=>3, "6"=>12, "5"=>1, "17"=>3, "16"=>3})

  #   end
  # end
#   describe "#games_by_team" do 
#     xit 'will find the amount of home games per team' do
#       expect(@game_stats.games_by_team("home")).to be_instance_of(Hash)
#       #this test is for the fixture
#       expect(@game_stats.games_by_team("home")).to eq({"3"=>2, "6"=>5, "5"=>2, "17"=>1, "16"=>2})
#     end

#     xit 'will find the amount of away games per team' do
#       expect(@game_stats.games_by_team("away")).to be_instance_of(Hash)
#       #this test is for the fixture
#       expect(@game_stats.games_by_team("away")).to eq({"3"=>3, "6"=>4, "5"=>2, "17"=>2, "16"=>1})
#     end
#   end
  
#   describe "#average_goals_per_team" do
#     xit "calculates average away goals per team" do
#       expect(@game_stats.average_goals_per_team("away")).to eq({"3"=>1.67, "6"=>3.0, "5"=>0.5, "17"=>1.5, "16"=>1.0})
#     end
#     xit "calculates average home goals per team" do
#       expect(@game_stats.average_goals_per_team("home")).to eq({"3"=>1.5, "6"=>2.4, "5"=>0.5, "17"=>3, "16"=>1.5})
#     end
#   end

#   describe "#highest_scoring_visitor" do
#     it 'finds team with highest average score when away' do
#     #this test is for the fixture
#     # expect(@game_stats.highest_scoring_visitor).to eq("FC Dallas")
#     expect(@game_stats.highest_scoring_visitor).to eq("6")
#     #for full data
#     # expect(@stat_tracker.highest_scoring_visitor).to eq "FC Dallas"
#     end
#   end
#     describe "#lowest_scoring_visitor" do
#       it 'finds team with lowest average score when away' do
#     #this test is for the fixture
#     # expect(@game_stats.lowest_scoring_visitor).to eq("Sporting Kansas City")
#     # expect(@game_stats.lowest_scoring_visitor).to eq("5")
#     #for full data
#     expect(@game_stats.lowest_scoring_visitor).to eq("27")
#     # expect(@stat_tracker.lowest_scoring_visitor).to eq "San Jose Earthquakes"
#     end
#   end
#   describe "#highest_scoring_home_team" do
#   it 'finds team with highest average score when away' do
#     #this test is for the fixture
#         # expect(@game_stats.highest_scoring_home_team).to eq("LA Galaxy")
#         # expect(@game_stats.highest_scoring_home_team).to eq("17")
#         #for full data
#         expect(@game_stats.highest_scoring_home_team).to eq("54")
#         # expect(@stat_tracker.lowest_scoring_visitor).to eq "Reign FC"
#       end
#     end

#     describe "#lowest_scoring_home_team" do
#       it 'finds team with lowest average score when away' do
#         # expect(@game_stats.lowest_scoring_home_team).to eq("Sporting Kansas City")
#         # expect(@game_stats.lowest_scoring_home_team).to eq("5")
#         #for full data
#         expect(@game_stats.lowest_scoring_home_team).to eq("7")
#         # expect(@stat_tracker.lowest_scoring_home_team).to eq "Utah Royals FC"
#       end
#     end

#     describe "#count of teams" do
#       it 'tells total number of teams' do
#         expect(@game_stats.count_of_teams).to be_instance_of(Integer)
#         expect(@game_stats.count_of_teams).to eq 32
#       end
#     end
#   end
# end