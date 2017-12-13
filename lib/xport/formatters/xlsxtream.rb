# frozen_string_literal: true

module Xport
  module Xlsxtream
    extend ActiveSupport::Concern

    included do
      require 'xlsxtream'
    end

    def to_xlsx(&block)
      formatter = Xport::Xlsxtream::Formatter.new(self)
      to_file(formatter, &block)
    end

    class Formatter
      attr_reader :export, :workbook

      delegate :builder, to: :export

      def initialize(export)
        @io       = StringIO.new
        @workbook = ::Xlsxtream::Workbook.new(@io)
        @io.rewind
      end

      def to_file
        workbook.close
        @io.rewind
        @io
      end

      def add_worksheet(&block)
        workbook.write_worksheet('Sheet1', use_shared_strings: true, &block)
      end

      def add_row(worksheet, row)
        values = row.map { |v| v.is_a?(Xport::Cell) ? v.value : v }
        worksheet << values
      end
      alias_method :add_header_row, :add_row

      def merge_header_cells(worksheet, range); end
      def column_widths(worksheet, *widths); end
    end
  end
end
