class SetTablesCharset < ActiveRecord::Migration[5.0]
  def self.up
    # Change database default charset to UTF-8
    execute "ALTER DATABASE #{current_database} DEFAULT CHARACTER SET utf8"

    # Convert tables to UTF-8 charset
    [
      'ar_internal_metadata',
      'binary_releases',
      'bs_request_counter',
      'cloud_ec2_configurations',
      'cloud_user_upload_jobs',
      'data_migrations',
      'download_repositories',
      'group_maintainers',
      'history_elements',
      'incident_updateinfo_counter_values',
      'kiwi_descriptions',
      'kiwi_images',
      'kiwi_package_groups',
      'kiwi_packages',
      'kiwi_preferences',
      'kiwi_repositories',
      'maintained_projects',
      'notifications',
      'product_media',
      'product_update_repositories'
    ].each do |table|
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8"
    end

    # Convert columns changed to MEDIUMTEXT during conversion back to TEXT
    execute "ALTER TABLE download_repositories MODIFY pubkey TEXT"
    execute "ALTER TABLE history_elements MODIFY comment TEXT"
    execute "ALTER TABLE notifications MODIFY event_payload TEXT NOT NULL"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
