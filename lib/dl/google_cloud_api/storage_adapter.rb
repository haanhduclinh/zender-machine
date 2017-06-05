require "google/cloud/storage"

module Dl
  module GoogleCloudApi
    class StorageAdapter
      def initialize(project:, bucket:, keyfile_json_path: nil)
        storage = Google::Cloud::Storage.new(
          project: project,
          keyfile: keyfile_json_path
        )

        @bucket = storage.bucket(bucket)
      end

      def file_by_id(id)

      end
    end
  end
end

it-kn-media-prod
storage.googleapis.com/it-kn-media-prod/2017/02/webhosting-with-vdeck-control-board.png