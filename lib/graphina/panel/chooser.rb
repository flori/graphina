require 'search_ui'
require 'amatch'

# A module that provides functionality for choosing panels from a configuration
#
# The Panel::Chooser module implements a search-based interface for selecting
# from available panel configurations. It integrates with terminal-based user
# interfaces to allow interactive selection of panels with fuzzy matching and
# visual feedback during the selection process
module Graphina::Panel::Chooser
  class << self
    include SearchUI
    include Term::ANSIColor

    # The choose method presents an interactive selection interface for
    # available panels
    #
    # This method implements a search-based user interface that allows users to
    # select from a collection of predefined panel configurations. It utilizes
    # fuzzy matching to find relevant panel names and provides visual feedback
    # during the selection process with a colored highlight for the currently
    # selected option
    #
    # @param panels [ Hash ] a hash (convertible) containing panel
    #   configurations indexed by name
    #
    # @return [ Graphina::Panel, nil ] returns a new Panel instance configured
    #   with the selected panel's settings, or nil if no panel was chosen
    def choose(panels)
      panel_names = panels.to_h.keys
      panel = Search.new(
        prompt: 'Choose a panel? ',
        match: -> answer {
          matcher = Amatch::PairDistance.new(answer.downcase)
          matches = panel_names.map { |n| [ n, -matcher.similar(n.to_s.downcase) ] }.
            select { |_, s| s < 0 }.sort_by(&:last).map(&:first)
          matches.empty? and matches = panel_names
          matches.first(Tins::Terminal.lines - 1)
        },
        query: -> _answer, matches, selector {
          matches.each_with_index.
          map { |m, i| i == selector ? on_blue { m } : m } * ?\n
        },
        found: -> _answer, matches, selector {
          matches[selector]
        },
        output: STDOUT
      ).start
      if panel
        Graphina::Panel.new(panels[panel])
      else
        puts
      end
    end
  end
end
