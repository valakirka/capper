require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  set(:monitrc) { "#{deploy_to}/.monitrc.local" }

  namespace :monit do
    desc "Setup monit configuration files"
    task :setup do
      configs = fetch(:monit_configs, {})

      upload_template(monitrc, :mode => "0644") do |server|
        configs.keys.select do |name|
          options = configs[name][:options]
          find_servers(options).include?(server)
        end.map do |name|
          "# #{name}\n#{configs[name][:body]}"
        end.join("\n\n")
      end
    end

    desc "Reload monit configuration"
    task :reload do
      run "monit reload &>/dev/null && sleep 1"
    end
  end

  after "deploy:update_code", "monit:setup"
  before "deploy:restart", "monit:reload"
end
