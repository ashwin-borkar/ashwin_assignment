# questionnaire_spec.rb

require 'pstore'
require_relative 'questionnaire'  # Assuming your Questionnaire class is in a separate file named questionnaire.rb

describe Questionnaire do
  let(:store_path) { 'tendable.pstore' }
  let(:questionnaire) { Questionnaire.new }

  before(:each) do
    # Clear any existing data in the PStore file before each test
    File.delete(store_path) if File.exist?(store_path)
  end

  describe '#do_prompt' do
    it 'stores user answers in PStore' do
      allow(questionnaire).to receive(:gets).and_return('yes', 'yes', 'no', 'yes', 'no')  # Simulate user input for questions

      expect {
        questionnaire.do_prompt
      }.to change {
        store = PStore.new(store_path)
        store.transaction { store[:answers]&.size || 0 }  # Handle case where store[:answers] might be nil
      }.by(1)
    end
  end

  describe '#calculate_rating' do
    it 'calculates correct rating based on answers' do
      answers = {
        "q1" => "yes",
        "q2" => "yes",
        "q3" => "no",
        "q4" => "yes",
        "q5" => "no"
      }

      rating = questionnaire.calculate_rating(answers)
      expect(rating).to eq(60.0)
    end
  end

  describe '#do_report' do
    it 'prints correct average rating when answers are present' do
      # Mock data in the store
      store = PStore.new(store_path)
      store.transaction do
        store[:answers] = [
          {"q1" => "yes", "q2" => "no", "q3" => "yes", "q4" => "yes", "q5" => "no"},
          {"q1" => "yes", "q2" => "yes", "q3" => "yes", "q4" => "no", "q5" => "yes"}
        ]
      end

      expect {
        questionnaire.do_report
      }.to output(/Run 1: Rating 60.0%\nRun 2: Rating 80.0%\nAverage Rating: 70.0%/).to_stdout
    end

    it 'prints correct message when no answers are present' do
      # No answers in the store
      store = PStore.new(store_path)
      store.transaction do
        store[:answers] = []
      end

      expect {
        questionnaire.do_report
      }.to output(/No runs recorded yet/).to_stdout
    end
  end
end
