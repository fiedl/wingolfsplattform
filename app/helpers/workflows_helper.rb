require_dependency YourPlatform::Engine.root.join('app/helpers/workflows_helper').to_s

module WorkflowsHelper

  alias_method :original_link_to_workflow, :link_to_workflow

  def link_to_workflow(workflow, context_infos = {})

    if workflow.name == "Reaktivierung"
      # Den Reaktivierungs-Link im Moment garnicht anzeigen, weil er defekt ist.
      # Wir zeigen ihn wieder, wenn das Workflow-System umgestellt ist
      # und unser Backend Reaktivierungen unterstützt.
      #
      # link_to(icon("chevron-up") + " Reaktivierung (zur Zeit defekt)", "#", class: context_infos[:class])
    else
      original_link_to_workflow(workflow, context_infos)
    end

  end
end
