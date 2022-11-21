# frozen_string_literal: true

class ObjetPageComponent < ViewComponent::Base
  attr_reader :objet

  renders_one :cta

  def initialize(objet:)
    @objet = objet
    super
  end
end