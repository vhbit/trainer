require 'json'

module Trainer
  class PhabGenerator
    attr_accessor :results

    def initialize(results)
      self.results = results
    end

    def generate
      json_data = []
      self.results.each do |test_suite|
        test_suite[:tests].each do |test_case|
          phab_case = {
            namespace: test_case[:test_group],
            name: test_case[:name],
            result: test_case[:status] == 'Success' ? 'pass' : 'fail',
            duration: test_case[:duration]
          }

          unless test_case[:failures].nil?
            messages = test_case[:failures].collect do |failure|
              failure[:failure_message]
            end
            phab_case[:details] = messages.join("\n")
            # phab_case[:path] = failure[:file_name]
          end
          json_data.push(phab_case)
        end
      end

      json = JSON.generate(json_data)
      json = json.gsub('system_', 'system-').delete("\e") # Jenkins can not parse 'ESC' symbol
      return json
    end
  end
end
