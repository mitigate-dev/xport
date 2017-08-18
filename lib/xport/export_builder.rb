# frozen_string_literal: true

module Xport
  class ExportBuilder
    attr_reader :export, :columns, :headers, :groups, :styles, :types, :widths, :blocks

    def initialize(export, &block)
      @export  = export
      @columns = []
      @headers = []
      @groups  = []
      @styles  = []
      @types   = []
      @widths  = []
      @blocks  = []
      instance_exec(export, &block)
    end

    def column(name, type: nil, style: nil, width: nil, header: nil, group: nil, &block)
      columns << name
      headers << (header || name)
      groups  << group
      types   << type
      styles  << style
      widths  << width
      blocks  << block
    end

    def grouped?
      groups.any?
    end

    def groups_with_offset_and_colspan
      offset  = 0
      colspan = 1
      [].tap do |result|
        groups.each do |group|
          last = result.last
          # check if current group is same as last group
          if last && last[0] == group
            # if group is the same, update colspan
            last[2] += 1
          else
            result << [group, offset, colspan]
          end
          offset  += 1
        end
      end
    end
  end
end
