require "json"
require "shellwords"

module Fastlane
  module Actions
    class VerifyAppIconAction < Action
      ICONSET_PATH = "CountThat/Assets.xcassets/AppIcon.appiconset"

      def self.run(params)
        contents_path = File.join(ICONSET_PATH, "Contents.json")
        UI.user_error!("App icon Contents.json not found at #{contents_path}") unless File.exist?(contents_path)

        contents = JSON.parse(File.read(contents_path))
        filenames = contents["images"].map { |image| image["filename"] }.compact.uniq
        UI.user_error!("No icon image files referenced in #{contents_path}") if filenames.empty?

        errors = []

        filenames.each do |filename|
          icon_path = File.join(ICONSET_PATH, filename)

          unless File.exist?(icon_path)
            errors << "#{icon_path} is referenced in Contents.json but does not exist"
            next
          end

          properties = sips_properties(icon_path)

          if properties["hasAlpha"] == "yes"
            errors << "#{icon_path} has an alpha channel — App Store Connect rejects app icons with " \
                       "transparency. Flatten it onto an opaque background before uploading."
          end

          width = properties["pixelWidth"]
          height = properties["pixelHeight"]
          if width != "1024" || height != "1024"
            errors << "#{icon_path} is #{width}x#{height} — the app icon must be exactly 1024x1024"
          end
        end

        UI.user_error!("App icon validation failed:\n#{errors.map { |e| "  - #{e}" }.join("\n")}") unless errors.empty?

        UI.success("App icon validation passed (#{filenames.size} image(s) checked)")
      end

      def self.sips_properties(path)
        output = Actions.sh("sips -g hasAlpha -g pixelWidth -g pixelHeight #{path.shellescape}", log: false)
        output.lines.each_with_object({}) do |line, properties|
          key, value = line.strip.split(": ", 2)
          properties[key] = value if value
        end
      end

      def self.description
        "Verifies the app icon has no alpha channel and is the correct size"
      end

      def self.details
        "Reads Assets.xcassets/AppIcon.appiconset/Contents.json, checks every referenced icon image " \
        "with `sips`, and fails if any icon has transparency or isn't 1024x1024. Apple rejects app " \
        "icons with an alpha channel at TestFlight/App Store upload."
      end

      def self.authors
        ["CountThat"]
      end

      def self.available_options
        []
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
