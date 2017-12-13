# frozen_string_literal: true

module Xport
  module RubyXL
    extend ActiveSupport::Concern

    included do
      require 'rubyXL'
    end

    def to_xlsx(&block)
      formatter = Xport::RubyXL::Formatter.new(self)
      to_file(formatter, &block)
    end

    class Formatter
      attr_reader :export, :workbook

      delegate :builder, to: :export

      def initialize(export)
        @export    = export
        @workbook  = ::RubyXL::Workbook.new
        @i = 0
      end

      def to_file
        workbook.stream
      end

      def add_worksheet
        worksheet = workbook.worksheets[0]
        yield worksheet
      end

      def add_row(worksheet, row)
        row.each.with_index do |v, j|
          value = v.is_a?(Xport::Cell) ? v.value : v
          worksheet.add_cell(@i, j, value)
        end
        @i += 1
      end
      alias_method :add_header_row, :add_row

      def merge_header_cells(worksheet, range)
        worksheet.merge_cells(0, range.first, 0, range.last)
      end

      def column_widths(worksheet, *widths)
        widths.each.with_index do |width, i|
          next unless width
          worksheet.change_column_width(i, width)
        end
      end
    end
  end
end
