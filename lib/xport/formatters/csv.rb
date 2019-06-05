# frozen_string_literal: true

module Xport
  module CSV
    extend ActiveSupport::Concern

    included do
      require 'csv'
    end

    def to_csv(&block)
      formatter = Xport::CSV::Formatter.new(self)
      to_file(formatter, &block)
    end

    def to_pgcsv
      StringIO.new.tap do |io|
        connection = object_class.connection
        query = connection.unprepared_statement do
          scope = object_class.from("(#{objects.to_sql}) AS #{object_class.table_name}")
          builder.columns.each_with_index do |column, i|
            name = builder.headers[i]
            as = human_attribute_name(name)
            scope = scope.select("#{column} AS \"#{as}\"")
          end
          "COPY (#{scope.to_sql}) TO STDOUT WITH CSV HEADER"
        end
        raw_connection = connection.raw_connection
        connection.send(:log, query) do
          res = raw_connection.copy_data query do
            while row = raw_connection.get_copy_data
              io << row
            end
          end
          res.check
        end
        io.rewind
      end
    end

    class Formatter
      def initialize(export)
        @io  = StringIO.new
        @csv = ::CSV.new(@io)
      end

      def to_file
        @io.rewind
        @io
      end

      def add_worksheet
        yield
      end

      def add_row(worksheet, row)
        values = row.map { |v| v.is_a?(Xport::Cell) ? v.value : v }
        @csv << values
      end
      alias_method :add_header_row, :add_row

      def merge_header_cells(worksheet, range); end
      def column_widths(worksheet, *widths); end
    end
  end
end
