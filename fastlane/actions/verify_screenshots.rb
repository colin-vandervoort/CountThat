module Fastlane
  module Actions
    class VerifyScreenshotsAction < Action
      SCREENSHOTS_PATH = "fastlane/screenshots"

      def self.run(params)
        paths = Dir.glob(File.join(SCREENSHOTS_PATH, "**", "*.png"))
        UI.user_error!("No screenshots found under #{SCREENSHOTS_PATH}") if paths.empty?

        errors = []

        paths.each do |path|
          header = File.open(path, "rb") { |f| f.read(40) }
          UI.message("#{path} header: #{header.inspect}")

          if header&.start_with?("version https://git-lfs")
            errors << "#{path} is a Git LFS pointer, not image data — run `git lfs pull` " \
                       "(or add `lfs: true` to the actions/checkout step) before verifying screenshots"
          end
        end

        UI.user_error!("Screenshot validation failed:\n#{errors.map { |e| "  - #{e}" }.join("\n")}") unless errors.empty?

        UI.success("Screenshot validation passed (#{paths.size} image(s) checked)")
      end

      def self.description
        "Verifies committed screenshots are real image data, not unresolved Git LFS pointers"
      end

      def self.details
        "Reads the first bytes of every PNG under fastlane/screenshots and fails if any of them is a " \
        "Git LFS pointer file instead of actual image data — this happens when actions/checkout doesn't " \
        "pull LFS content, and deliver would otherwise silently upload pointer text as a screenshot."
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
