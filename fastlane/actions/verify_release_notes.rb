module Fastlane
  module Actions
    class VerifyReleaseNotesAction < Action
      RELEASE_NOTES_PATH = "fastlane/metadata/en-US/release_notes.txt"

      def self.run(params)
        unless File.exist?(RELEASE_NOTES_PATH)
          UI.user_error!("#{RELEASE_NOTES_PATH} is missing — App Store review requires \"What's New\" " \
                          "text for this submission. Add it before releasing.")
        end

        if File.read(RELEASE_NOTES_PATH).strip.empty?
          UI.user_error!("#{RELEASE_NOTES_PATH} is empty — App Store review requires \"What's New\" " \
                          "text for this submission. Fill it in before releasing.")
        end

        UI.success("Release notes validation passed")
      end

      def self.description
        "Verifies release_notes.txt exists and has content before submitting to the App Store"
      end

      def self.details
        "Apple requires \"What's New\" text for App Store review on version updates. Rather than let " \
        "deliver silently skip a missing/blank release_notes.txt, fail the release lane early with a " \
        "clear message."
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
