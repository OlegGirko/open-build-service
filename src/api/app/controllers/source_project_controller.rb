class SourceProjectController < SourceController
  include CheckAndRemoveRepositories

  # GET /source/:project
  def show
    project_name = params[:project]
    if params.key?(:deleted)
      unless Project.find_by_name(project_name) || Project.remote_project?(project_name)
        # project is deleted or not accessible
        validate_visibility_of_deleted_project(project_name)
      end
      pass_to_backend
      return
    end

    if Project.remote_project?(project_name)
      # not a local project, hand over to backend
      pass_to_backend
      return
    end

    @project = Project.find_by_name(project_name)
    raise Project::UnknownObjectError, "Project not found: #{project_name}" unless @project

    # we let the backend list the packages after we verified the project is visible
    if params.key?(:view)
      case params[:view]
      when 'verboseproductlist'
        @products = Product.all_products(@project, params[:expand])
        render 'source/verboseproductlist', formats: [:xml]
        return
      when 'productlist'
        @products = Product.all_products(@project, params[:expand])
        render 'source/productlist', formats: [:xml]
        return
      when 'issues'
        render_project_issues
      when 'info'
        pass_to_backend
      else
        raise InvalidParameterError, "'#{params[:view]}' is not a valid 'view' parameter value."
      end
      return
    end

    render_project_packages
  end

  def render_project_issues
    set_issues_defaults
    render partial: 'source/project_issues', formats: [:xml]
  end

  def render_project_packages
    @packages = params.key?(:expand) ? @project.expand_all_packages : @project.packages.pluck(:name)
    render locals: { expand: params.key?(:expand) }, formats: [:xml]
  end

  # DELETE /source/:project
  def delete
    project = Project.get_by_name(params[:project])

    # checks
    unless project.is_a?(Project) && User.session.can_modify?(project)
      logger.debug "No permission to delete project #{project}"
      render_error status: 403, errorcode: 'delete_project_no_permission',
                   message: "Permission denied (delete project #{project})"
      return
    end
    project.check_weak_dependencies!
    opts = { no_write_to_backend: true,
             force: params[:force].present?,
             recursive_remove: params[:remove_linking_repositories].present? }
    check_and_remove_repositories!(project.repositories, opts)

    logger.info "destroying project object #{project.name}"
    project.commit_opts = { comment: params[:comment] }
    begin
      project.destroy
    rescue ActiveRecord::RecordNotDestroyed => e
      exception_message = "Destroying Project #{project.name} failed: #{e.record.errors.full_messages.to_sentence}"
      logger.debug exception_message
      raise ActiveRecord::RecordNotDestroyed, exception_message
    end

    render_ok
  end

  # POST /source/:project?cmd
  #-----------------
  def project_command
    # init and validation
    #--------------------
    required_parameters(:cmd)

    valid_commands = %w[undelete showlinked remove_flag set_flag createpatchinfo
                        createkey extendkey copy createmaintenanceincident lock
                        unlock release addchannels modifychannels move freezelink]

    raise IllegalRequest, 'invalid_command' unless valid_commands.include?(params[:cmd])

    command = params[:cmd]
    project_name = params[:project]
    params[:user] = User.session.login

    return dispatch_command(:project_command, command) if command.in?(%w[undelete release copy move])

    @project = Project.get_by_name(project_name)

    raise CmdExecutionNoPermission, "no permission to execute command '#{command}'" unless
      (command == 'unlock' && User.session.can_modify?(@project, true)) ||
      command == 'showlinked' ||
      User.session.can_modify?(@project)

    dispatch_command(:project_command, command)
  end
end
