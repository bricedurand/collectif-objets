# frozen_string_literal: true

require "active_support/concern"

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/MethodLength

module Communes
  module IncludeCountsConcern
    extend ActiveSupport::Concern

    included do
      def self.include_objets_count
        joins(
          %{
          LEFT OUTER JOIN (
            SELECT commune_code_insee, COUNT(*) objets_count
            FROM objets
            GROUP BY commune_code_insee
          ) a ON a.commune_code_insee = communes.code_insee
        }
        ).select("communes.*, COALESCE(a.objets_count, 0) AS objets_count")
      end

      def self.include_objets_recenses_count
        joins(
          %{
          LEFT OUTER JOIN (
            SELECT commune_code_insee, COUNT(*) objets_recenses_count
            FROM objets
            WHERE exists (SELECT id FROM recensements WHERE recensements.objet_id = objets.id)
            GROUP BY commune_code_insee
          ) b ON b.commune_code_insee = communes.code_insee

          LEFT OUTER JOIN (
            SELECT objets.commune_code_insee, COUNT(*) recensements_analysed_count
            FROM recensements
            INNER JOIN objets ON objets.id = recensements.objet_id
            WHERE recensements.analysed_at IS NOT NULL
            GROUP BY objets.commune_code_insee
          ) c ON c.commune_code_insee = communes.code_insee

          LEFT OUTER JOIN (
            SELECT objets.commune_code_insee, COUNT(*) recensements_prioritaires_count
            FROM recensements
            INNER JOIN objets ON objets.id = recensements.objet_id
            WHERE recensements.analyse_prioritaire IS TRUE
            GROUP BY objets.commune_code_insee
          ) d ON d.commune_code_insee = communes.code_insee
        }
        ).select(
          "communes.*," \
          "COALESCE(b.objets_recenses_count, 0) AS objets_recenses_count, " \
          "(COALESCE(100 * b.objets_recenses_count, 0)::float / COALESCE(a.objets_count, 1)) " \
          "AS objets_recenses_percentage, "\
          "(COALESCE(100 * c.recensements_analysed_count, 0)::float / COALESCE(a.objets_count, 1)) " \
          "AS recensements_analysed_percentage,"\
          "COALESCE(d.recensements_prioritaires_count, 0) as recensements_prioritaires_count"
        )
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/MethodLength