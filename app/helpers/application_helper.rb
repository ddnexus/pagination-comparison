require 'benchmark/ips'
require 'memory_profiler'
require 'classes'

module ApplicationHelper

  # normally in the controller (see Paginations note in the comparison_helper.rb)
  include Pagy::Frontend

  def wrap_nav(string, &block)
    out = "\n\n<!-- start #{string} -->\n"
    out << capture(&block)
    out << "\n<!-- end #{string} -->\n\n"
  end

  def fair_range?
    (12..28).cover? params[:page].to_i
  end

end
