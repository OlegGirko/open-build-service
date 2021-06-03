class ProjectMetaFile < ProjectFile
  def initialize(attributes = {})
    super
    @name = '_meta'
  end

  # calculates the real url on the backend to search the file
  def full_path(query = {})
    EscapeUtils.escape_uri("/source/#{project_name}/#{name}") + "?#{query.to_query}"
  end

  # You dont want to change name of _meta
  private :name=
end
