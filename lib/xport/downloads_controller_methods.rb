# frozen_string_literal: true

module Xport
  module DownloadsControllerMethods
    extend ActiveSupport::Concern

    included do
      before_action :set_download, only: %i(show update destroy)
      before_action :set_downloads, only: :index
    end

    def index; end

    def show
      respond_to do |format|
        format.html do
          if !request.xhr? && @download.file?
            redirect_to format: @download.type
          else
            render 'show'
          end
        end

        format.any(:xlsx, :csv) do
          send_data @download.file.read, filename: @download.filename
        end
      end
    end

    def update
      @download.schedule_export!
      redirect_to @download
    end

    def destroy
      @download.destroy
      redirect_to action: 'index'
    end

    private

    def resource_class
      controller_path.classify.constantize
    end

    def set_download
      @download = resource_class.find(params[:id])
    end

    def set_downloads
      @downloads = resource_class.page(params[:page])
    end
  end
end
