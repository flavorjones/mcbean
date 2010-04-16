require 'redcloth'

class McBean
  attr_writer :__textile__

  def McBean.textile string_or_io
    mcbean = new
    mcbean.__textile__ = McBean::Textilify::Antidote.new(string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io)
    mcbean
  end

  def __textile__ generate_from_html_if_necessary=true # :nodoc:
    @__textile__ ||= nil
  end

  class Textilify
    Antidote = ::RedCloth::TextileDoc
  end
end
