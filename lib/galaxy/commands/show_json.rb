module Galaxy
  module Commands
    class ShowJsonCommand < Command
      register_command "show-json"

      def report_class
        Galaxy::Client::SoftwareDeploymentJsonReport
      end

      def execute agents
        report.start
        report.format_json name_sort(agents)
        report.finish
      end

      def self.help
        return <<-HELP
#{name}
        
        Show json dump of software deployments on the selected hosts

        Examples:
        
        - Show json for all hosts:
            galaxy #{name}

        - Show json for unassigned hosts:
            galaxy -s empty #{name}

        - Show json for assigned hosts:
            galaxy -s taken #{name}

        - Show json for a specific host:
            galaxy -i foo.bar.com #{name}

        - Show json for all widgets:
            galaxy -t widget #{name}
                HELP
      end
    end
    
  end
end
