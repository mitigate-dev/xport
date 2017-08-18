# frozen_string_literal: true

module Xport
  class DownloadPresenter
    attr_reader :h

    def initialize(download, h)
      @download = download
      @h        = h
    end

    def progress_bar(job_id)
      return unless job_id
      job = Resque::Plugins::Status::Hash.get(job_id)
      return unless job

      case job.status
      when Resque::Plugins::Status::STATUS_COMPLETED
        nil
      when Resque::Plugins::Status::STATUS_QUEUED
        progress_bar_pending
      else
        h.content_tag(:div, class: 'progress', data: { component: 'Future.ProgressBar' }) do
          h.content_tag(:div, class: 'progress-bar', style: "width: #{job.pct_complete}%") do
            "#{job.pct_complete}% #{job.message}"
          end
        end
      end
    end

    def progress_bar_pending
      message = I18n.translate(
        'helpers.progress_bar.please_wait_pending',
        count: Resque.info[:pending]
      )

      h.content_tag(:div, class: 'progress', data: { component: 'Future.ProgressBar' }) do
        h.content_tag(:div, class: 'progress-bar progress-bar-pending', style: 'width: 100%') do
          h.content_tag(:span, message)
        end
      end
    end
  end
end
