class PathElement < ActiveRecord::Base
  belongs_to :repository, :foreign_key => 'parent_id', inverse_of: :path_elements
  belongs_to :link, :class_name => 'Repository', :foreign_key => 'repository_id', inverse_of: :links

  validates :link, presence: true
  validates :repository, presence: true
  validates :position, presence: true

  #def to_s
  # self.link.remote_project_name ? "#{self.link.project.name}:#{self.link.remote_project_name}/#{self.link.name}" : "#{self.link.project.name}/#{self.link.name}" 
  #end
end
