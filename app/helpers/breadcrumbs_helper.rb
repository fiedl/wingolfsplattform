# -*- coding: utf-8 -*-
module BreadcrumbsHelper

  # Erzeugt eine ungeordnete Liste der Breadcrumb-Elemente für das navigationsfähige Objekt +navable+, 
  # z.B. einen Benutzer (User) oder eine Seite (Page).
  def breadcrumb_ul_for_navable( navable )
    content_tag :ul do
      breadcrumbs = navable.nav_node.breadcrumbs
      breadcrumbs.collect do |breadcrumb|
        css_class = "crumb"
        css_class = "root crumb" if breadcrumb == breadcrumbs.first
        css_class = "last crumb" if breadcrumb == breadcrumbs.last
        css_class += " slim" if breadcrumb[ :slim ]
        c = content_tag :li, :class => css_class do
          link_to breadcrumb[ :title ], breadcrumb[ :navable ]
        end
        unless breadcrumb == breadcrumbs.last
          c+= content_tag :li, "&nbsp;".html_safe, :class => "crumb sep"
        end
        c
      end.join.html_safe
    end
  end

  def breadcrumb_ul
    breadcrumb_ul_for_navable @navable if @navable
  end

end
