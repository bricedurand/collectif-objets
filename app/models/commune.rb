class Commune < ApplicationRecord
  has_many :objets, foreign_key: :commune_code_insee, primary_key: :code_insee

  def self.include_objets_count
    joins(
     %{
       LEFT OUTER JOIN (
         SELECT commune_code_insee, COUNT(*) objets_count
         FROM   objets
         GROUP BY commune_code_insee
       ) a ON a.commune_code_insee = communes.code_insee
     }
    ).select("communes.*, COALESCE(a.objets_count, 0) AS objets_count")
  end

  def main_objet
    @main_objet ||= begin
      objets_filtered = objets.where.not(nom: nil).to_a
      if objets_filtered.any?
        main_objet = objets_filtered.optional_filter { _1.image_urls.any? }
          .optional_filter { !_1.nom.include?(";") }
          .optional_filter { !_1.nom.match?(/[A-Z]/) }
          .optional_filter { _1.edifice_nom.present? }
          .optional_filter { _1.edifice_nom&.match?(/[A-Z]/) }
          .optional_filter { !_1.emplacement.present? }
          .first
      else
        nil
      end
    end
  end
end
