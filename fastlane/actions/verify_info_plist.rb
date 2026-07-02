require "plist"

module Fastlane
  module Actions
    class VerifyInfoPlistAction < Action
      INFO_PLIST_PATH = "CountThat/Info.plist"
      SOURCE_DIR = "CountThat"

      REQUIRED_KEYS = ["CFBundleIconName", "ITSAppUsesNonExemptEncryption"].freeze

      # API symbol => Info.plist usage-description key(s); at least one of the
      # mapped keys must be present if the symbol shows up in source.
      PRIVACY_API_USAGE_KEYS = {
        "AVCaptureDevice" => ["NSCameraUsageDescription"],
        "CLLocationManager" => ["NSLocationWhenInUseUsageDescription", "NSLocationAlwaysAndWhenInUseUsageDescription"],
        "PHPhotoLibrary" => ["NSPhotoLibraryUsageDescription"],
        "CNContactStore" => ["NSContactsUsageDescription"],
        "HKHealthStore" => ["NSHealthShareUsageDescription", "NSHealthUpdateUsageDescription"],
        "CBCentralManager" => ["NSBluetoothAlwaysUsageDescription"],
        "SFSpeechRecognizer" => ["NSSpeechRecognitionUsageDescription"],
        "EKEventStore" => ["NSCalendarsUsageDescription", "NSRemindersUsageDescription"],
        "CMMotionManager" => ["NSMotionUsageDescription"],
        "ATTrackingManager" => ["NSUserTrackingUsageDescription"]
      }.freeze

      def self.run(params)
        UI.user_error!("Info.plist not found at #{INFO_PLIST_PATH}") unless File.exist?(INFO_PLIST_PATH)

        info_plist = Plist.parse_xml(File.read(INFO_PLIST_PATH))
        errors = []

        REQUIRED_KEYS.each do |key|
          errors << "#{INFO_PLIST_PATH} is missing required key #{key}" unless info_plist.key?(key)
        end

        source_files = Dir.glob(File.join(SOURCE_DIR, "**", "*.swift"))
        source_text = source_files.map { |file| File.read(file) }.join("\n")

        PRIVACY_API_USAGE_KEYS.each do |api_symbol, usage_keys|
          next unless source_text.include?(api_symbol)
          next if usage_keys.any? { |key| info_plist.key?(key) }

          errors << "#{SOURCE_DIR} uses #{api_symbol} but #{INFO_PLIST_PATH} has none of: #{usage_keys.join(", ")}"
        end

        UI.user_error!("Info.plist validation failed:\n#{errors.map { |e| "  - #{e}" }.join("\n")}") unless errors.empty?

        UI.success("Info.plist validation passed")
      end

      def self.description
        "Verifies Info.plist has required keys and privacy usage descriptions for any sensitive APIs used"
      end

      def self.details
        "Checks CFBundleIconName and ITSAppUsesNonExemptEncryption are set, and cross-checks source for " \
        "privacy-sensitive API usage (camera, location, photos, contacts, health, bluetooth, etc.) against " \
        "the matching NS*UsageDescription key. Missing usage descriptions are a common late-stage " \
        "TestFlight/App Store processing rejection."
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
