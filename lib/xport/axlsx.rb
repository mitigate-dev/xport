# frozen_string_literal: true

module Xport
  module Axlsx
    extend ActiveSupport::Concern

    included do
      require 'axlsx'
    end

    def to_xlsx(&block)
      formatter = Xport::Axlsx::Formatter.new(self)
      to_file(formatter, &block)
    end

    class Formatter
      attr_reader :export, :workbook, :worksheet

      delegate :builder, to: :export

      def initialize(export)
        @export    = export
        @package   = ::Axlsx::Package.new
        @workbook  = @package.workbook
        @worksheet = @workbook.add_worksheet

        # Support Numbers and multiline strings in Excel Mac 2011
        # https://github.com/randym/axlsx/issues/252
        @package.use_shared_strings = true
      end

      def to_file
        @package.to_stream
      end

      def add_header_row(row)
        worksheet.add_row row, style: header_style
      end

      def add_row(row)
        values = row.map { |v| v.is_a?(Xport::Cell) ? v.value : v }
        axlsx_row = worksheet.add_row(values, style: styles, types: builder.types)
        row.each.with_index do |cell, i|
          next unless cell.is_a?(Xport::Cell)
          axlsx_cell = axlsx_row.cells[i]
          axlsx_cell.color = cell.color
          if cell.comment
            worksheet.add_comment(
              ref: axlsx_cell.reference(false),
              author: 'Conditions',
              text: cell.comment,
              visible: false
            )
          end
        end
      end

      def merge_header_cells(range)
        worksheet.merge_cells worksheet.rows.first.cells[range]
      end

      def column_widths(*widths)
        worksheet.column_widths(*widths)
      end

      private

      def styles
        @styles ||= builder.styles.map do |options|
          workbook.styles.add_style(options) if options
        end
      end

      def header_style
        @header_style ||= workbook.styles.add_style b: true
      end
    end
  end
end
