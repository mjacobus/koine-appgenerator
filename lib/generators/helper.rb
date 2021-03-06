module Koine
  module Generators
    module Helper

      def copy_dir(directory, options = {})
        base = self.class.templates_path + "/"
        Dir[base + "#{directory}/**/*"].each do |file|
          unless File.directory?(file)
            file        = file.gsub(base, "")
            source      = file
            destination = file.gsub(/\.erb$/, '')
            copy_file(source, destination, options)
          end
        end
      end

      def template_dir(directory, options = {})
        base = self.class.templates_path + "/"
        Dir[base + "#{directory}/**/*"].each do |file|
          unless File.directory?(file)
            file        = file.gsub(base, "")
            source      = file
            destination = file.gsub(/\.erb$/, '')
            template(source, destination, options)
          end
        end
      end

      def replace_in_file(relative_path, find, replace)
        path = File.join(destination_root, relative_path)
        contents = IO.read(path)
        unless contents.gsub!(find, replace)
          raise "#{find.inspect} not found in #{relative_path}"
        end
        File.open(path, "w") { |file| file.write(contents) }
      end

      def action_mailer_host(rails_env, host)
        host_config = "config.action_mailer.default_url_options = { host: '#{host}' }"
        configure_environment(rails_env, host_config)
      end

      def configure_environment(rails_env, config)
        inject_into_file(
          "config/environments/#{rails_env}.rb",
          "\n\n  #{config}",
          before: "\nend"
        )
      end

      def download_file(uri_string, destination)
        uri = URI.parse(uri_string)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri_string =~ /^https/
        request = Net::HTTP::Get.new(uri.path)
        contents = http.request(request).body
        path = File.join(destination_root, destination)
        File.open(path, "w") { |file| file.write(contents) }
      end

      def git_ignore(file)
        run "echo #{file} >> .gitignore"
      end

      def rename_file(source, destination)
        return if source == destination
        copy_file source, destination
        remove_file source
      end
    end
  end
end
