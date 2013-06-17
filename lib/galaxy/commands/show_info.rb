module Galaxy
  module Commands
    class ShowInfoCommand < Command
      register_command "show-info"

      def report_class
        Galaxy::Client::CoreSlotInfoReport
      end

      def execute agents
        report.start
        name_sort(agents).each do |agent|
            report.record_result agent
        end
        report.finish
      end

      def self.help
        return <<-HELP
#{name}
        
        Shows the slot information on the selected agents.
                HELP
      end
    end
    
  end
end
