# frozen_string_literal: true

module Xport
  module ExportControllerMethods
    def xport_export(export, filename:)
      download = export.download(filename: filename, user: current_user)
      if download
        redirect_to download
      else
        send_data export.to_file.read, filename: filename
      end
    end
  end
end
