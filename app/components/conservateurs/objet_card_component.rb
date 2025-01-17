# frozen_string_literal: true

module Conservateurs
  class ObjetCardComponent < ViewComponent::Base
    def initialize(objet, commune:, recensement: nil, can_analyse: false)
      @objet = objet
      @recensement = recensement
      @can_analyse = can_analyse
      @commune = commune
      super
    end

    def call
      render ::ObjetCardComponent.new(
        objet, commune:, badges:, main_photo_origin: :recensement_or_memoire, path:, tags:, link_html_attributes:
      )
    end

    private

    attr_reader :objet, :recensement, :can_analyse, :commune

    def path
      if can_analyse
        edit_conservateurs_objet_recensement_analyse_path(objet, recensement)
      else
        objet_path(objet)
      end
    end

    def badges
      return [] unless can_analyse

      @badges ||= [analysed_badge, prioritaire_badge].compact
    end

    def tags
      return [] unless can_analyse

      @tags ||= [not_recensed_badge, missing_photos_badge].compact
    end

    def badge_struct
      Struct.new(:color, :text)
    end

    def not_recensed_badge
      return nil if recensement.present?

      badge_struct.new("warning", "Pas encore recensé")
    end

    def missing_photos_badge
      return nil unless recensement&.missing_photos?

      badge_struct.new "warning", "photos manquantes"
    end

    def analysed_badge
      return nil unless recensement&.analysed?

      badge_struct.new "success", "Analysé"
    end

    def prioritaire_badge
      return nil unless recensement&.prioritaire?

      badge_struct.new "warning", "Prioritaire"
    end

    def link_html_attributes
      @link_html_attributes = { data: { turbo_action: "advance" } }
      @link_html_attributes[:data][:turbo_frame] = "_top" unless can_analyse
      @link_html_attributes
    end
  end
end
