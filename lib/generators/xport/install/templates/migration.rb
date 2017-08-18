# frozen_string_literal: true

class CreateDownloads < ActiveRecord::Migration
  def up
    create_table :downloads do |t|
      t.string   :user_id
      t.string   :file_filename
      t.string   :filename
      t.string   :job_id
      t.string   :export_klass_name
      t.string   :export_model_name
      t.text     :query
      t.integer  :records_count
      t.datetime :exported_at
      t.string   :export_additional_columns, array: true, default: []
      t.timestamps
    end
  end

  def down
    drop_table :downloads
  end
end
