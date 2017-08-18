# frozen_string_literal: true

module Xport
  class Export
    attr_reader :workbook, :objects, :builder

    class_attribute :builder_block

    def self.columns(&block)
      self.builder_block = block
    end

    def initialize(objects = [])
      @objects = objects
      @builder = Xport::ExportBuilder.new(self, &builder_block)
    end

    def to_file(formatter = nil, &block)
      preload!
      # TODO: There shouldn't be a default formatter
      formatter ||= Xport::Axlsx::Formatter.new(self)
      write_contents(formatter, &block)
      formatter.to_file
    end

    def object_class
      self.class.name.sub(/Export/, '').singularize.constantize
    end

    # TODO: Extract to xport-downloads?
    def download(filename:, user: nil)
      return unless objects.respond_to?(:to_sql)
      download                   = download_class.new
      download.user              = user
      download.export_klass_name = self.class.name

      if objects.respond_to?(:model)
        download.export_model_name = objects.model.name
      end
      if respond_to?(:additional_columns)
        download.export_additional_columns = additional_columns
      end
      # TODO: Remove `unprepared_statement` call when `to_sql` is fixed
      # https://github.com/rails/rails/issues/18379
      object_class.connection.unprepared_statement do
        download.query = objects.to_sql
      end
      download.filename = filename
      download.save!
      download.schedule_export!
      download
    end

    def download_class
      module_name = self.class.to_s.deconstantize
      if module_name.present?
        "#{module_name}::Download".constantize
      else
        Download
      end
    end

    private

    def preload!; end

    def write_contents(formatter, &block)
      write_header(formatter)
      write_body(formatter, &block)
      write_widths(formatter)
    end

    def write_header(formatter)
      if builder.grouped?
        group_row = []
        builder.groups_with_offset_and_colspan.each do |group, offset, colspan|
          group_row << human_attribute_name(group)
          (colspan - 1).times do
            group_row << nil
          end
        end
        formatter.add_header_row group_row

        builder.groups_with_offset_and_colspan.each do |group, offset, colspan|
          colspan -= 1
          formatter.merge_header_cells(offset..offset + colspan)
        end
      end
      formatter.add_header_row header_row
    end

    def write_body(formatter)
      each_object do |object, rownum|
        yield rownum, objects.size if block_given?
        formatter.add_row object_row(object)
      end
    end

    def write_widths(formatter)
      formatter.column_widths(*builder.widths)
    end

    def find_in_batches?
      false
    end

    def each_object(&block)
      if find_in_batches?
        objects.find_each.with_index(&block)
      else
        objects.each_with_index(&block)
      end
    end

    def header_row
      builder.headers.map do |name|
        human_attribute_name(name)
      end
    end

    def human_attribute_name(name)
      return if name.to_s.start_with?('empty')

      klass = object_class
      case name
      when String
        name
      when Symbol
        klass.human_attribute_name(name)
      end
    end

    def object_row(object)
      builder.columns.map.with_index do |name, index|
        block = builder.blocks[index]
        if block
          value = instance_exec(object, &block)
        elsif respond_to?(name, true)
          value = send(name, object)
        else
          value = object.send(name)
          if respond_to?("convert_#{name}", true)
            value = send("convert_#{name}", value)
          end
        end
        value
      end
    end

    def helper
      ApplicationController.helpers
    end
  end
end
